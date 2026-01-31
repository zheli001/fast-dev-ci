# Fast Dev CI — Dual-Mode Fast Feedback for Cloud CI/CD

<!-- Status strip -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Fast Dev CI is not a faster deployment pipeline.**
> It is a layered verification strategy that decouples *developer feedback* from *release deployment*, designed for **GitHub Actions**, **cloud runners**, and **cloud-hosted runtimes**.

This repository provides:

* A **Best Practice specification**
* A **dual-mode CI model** (no local deploy vs local runtime)
* A **ready-to-use GitHub Actions skeleton**
* A **configurable Local Runtime Profile (LRP)** schema

---

## 📋 Table of Contents

- [⚠️ 1. Problem Statement (Why This Exists)](#⚠️-1-problem-statement-why-this-exists)
- [🎯 2. Core Concept: Dual-Mode Fast Dev CI](#🎯-2-core-concept-dual-mode-fast-dev-ci)
- [🔄 3. Pipeline Flow Overview](#🔄-3-pipeline-flow-overview)
- [⚙️ 4. Local Runtime Profile (LRP)](#⚙️-4-local-runtime-profile-lrp)
- [📁 5. Repository Structure](#📁-5-repository-structure)
- [🚀 6. GitHub Actions — Mode 1 (Fast Verification)](#🚀-6-github-actions--mode-1-fast-verification)
- [🏃 7. GitHub Actions — Mode 2 (Local Runtime CI)](#🏃-7-github-actions--mode-2-local-runtime-ci)
- [❌ 8. What This Is NOT](#❌-8-what-this-is-not)
- [📈 9. Adoption Strategy](#📈-9-adoption-strategy)
- [💡 10. Guiding Principle (Final)](#💡-10-guiding-principle-final)
- [📜 License](#📜-license)

---

## ⚠️ 1. Problem Statement (Why This Exists)

Most teams using GitHub Actions and cloud runtimes face the same reality:

* CI pipelines take **10–30 minutes** for trivial changes
* Deployment is used as a **validation mechanism**
* Runtimes are **slow, remote, immutable**
* LLM-assisted development increases change volume

**Result:** CI becomes too slow for thinking.

Fast Dev CI addresses this by separating *fast confidence* from *slow certainty*.

---

## 🎯 2. Core Concept: Dual-Mode Fast Dev CI

Fast Dev CI operates in **two complementary modes**.

### Mode 1 — Pre-deploy Fast Verification (Default)

Covers ~90% of changes **without any deployment**.

Used when:

* Logic changes
* Refactors
* Contract-preserving changes
* Config / data shape changes

Characteristics:

* Incremental build
* Diff-scoped verification
* Contract & invariant checks
* No runtime dependency

This mode must be **fast, cheap, and always available**.

---

### Mode 2 — Local Runtime Fast CI (Optional)

Used for the remaining ~10% of changes where runtime behavior matters.

Used when:

* Side effects (IO / network)
* Concurrency or timing behavior
* Framework or infra glue code

Characteristics:

* Local or near-local runtime
* Configurable runtime profiles
* Fast, incomplete but meaningful validation

Mode 2 **never blocks Mode 1**.

---

## 🔄 3. Pipeline Flow Overview

```
All Changes
   │
   ▼
Mode 1: Fast Verification (CI)
   │
   ├── pass → promotion candidate
   │
   └── fail → stop immediately
   │
   ▼
Mode 2: Local Runtime CI (optional)
   │
   ▼
Release CI / Deployment
```

---

## ⚙️ 4. Local Runtime Profile (LRP)

Local Runtime Profiles allow **runtime behavior approximation** without production deployment.

### LRP Schema

```yaml
runtime_profile:
  name: local-fast
  base: prod
  overrides:
    io:
      network: mock        # mock | sandbox | real
      storage: replay      # replay | local | real
    concurrency:
      threads: 1
    time:
      mode: frozen         # frozen | real
    limits:
      timeout: 2s
    feature_flags:
      new_logic: on
```

Principles:

* `base: prod` anchors semantics
* Overrides are **explicit and reviewable**
* Profiles are versioned and shared

Same profile schema is used:

* Locally by developers
* In CI runners

---

## 📁 5. Repository Structure

```
fast-dev-ci/
├── README.md
├── .github/
│   └── workflows/
│       ├── fast-dev.yml        # Mode 1
│       ├── local-runtime.yml   # Mode 2
│       └── release.yml         # Traditional CI/CD
├── ci/
│   ├── diff-scope.sh
│   ├── build.sh
│   ├── verify.sh
│   └── runtime.sh
├── runtime-profiles/
│   ├── local-fast.yml
│   └── ci-fast.yml
└── examples/
    └── sample-service/
```

---

## 🚀 6. GitHub Actions — Mode 1 (Fast Verification)

```yaml
name: fast-dev

on:
  pull_request:
  push:

jobs:
  fast-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Compute change scope
        run: ./ci/diff-scope.sh

      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: ~/.cache/build
          key: fast-${{ env.SCOPE_HASH }}

      - name: Incremental build
        run: ./ci/build.sh $SCOPE

      - name: Verify invariants
        run: ./ci/verify.sh $SCOPE
```

Target duration: **30s – 3min**.

---

## 🏃 7. GitHub Actions — Mode 2 (Local Runtime CI)

```yaml
name: local-runtime-ci

on:
  workflow_dispatch:

jobs:
  local-runtime:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run local runtime
        run: |
          ./ci/runtime.sh \
            --profile runtime-profiles/ci-fast.yml
```

---

## ❌ 8. What This Is NOT

* ❌ A replacement for CI/CD
* ❌ A production deployment shortcut
* ❌ A promise of full correctness

Fast Dev CI answers only one question:

> **"Is this change worth sending into the slow system?"**

---

## 📈 9. Adoption Strategy

1. Introduce Mode 1 only (low friction)
2. Reduce Fast CI runtime below 3 minutes
3. Add runtime profiles for critical paths
4. Keep Release CI unchanged

---

## 💡 10. Guiding Principle (Final)

> **If a change cannot be meaningfully validated without deploying,
> then validation is in the wrong place.**

---

## 📜 License

MIT
