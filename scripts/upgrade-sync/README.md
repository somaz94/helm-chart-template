# upgrade-sync

Canonical templates and a sync tool for the per-chart `upgrade.sh` scripts.

Each helmfile-based chart (`aws/external-dns/`, `aws/gitlab-runner-aws/`,
`gcp/external-dns/`) has an `upgrade.sh` for version upgrades. The script
bodies are nearly identical, so they are managed in one place (this directory)
and propagated to every chart via [sync.sh](sync.sh).

To survey which charts have an upstream upgrade available before touching any
`upgrade.sh`, use [check-versions.sh](check-versions.sh) (read-only).

To inspect or bulk-clean the `backup/` directories across every chart at once,
use [manage-backups.sh](manage-backups.sh).

<br/>

## Directory layout

```
scripts/upgrade-sync/
├── README.md                          # this file
├── sync.sh                            # sync tool (cross-platform)
├── check-versions.sh                  # upgrade preflight (read-only)
├── manage-backups.sh                  # bulk backup management (list/cleanup/purge)
└── templates/
    ├── external-standard.sh           # external chart (helm repo) + default flow
    ├── external-with-image-tag.sh     # external chart + automatic values image-tag bump
    ├── local-with-templates.sh        # local chart (Chart.yaml in repo) + custom template preservation
    ├── local-cr-version.sh            # local chart (CR wrapper) + values.version field tracking
    └── ansible-github-release.sh      # Ansible-deployed component + GitHub Releases feed
```

<br/>

## Core concept

Each chart's `upgrade.sh` is split into two regions:

```bash
#!/bin/bash
# upgrade-template: external-standard       <-- header: declares which canonical to follow
set -euo pipefail

# ============================================================
# Configuration (per-chart)
# ============================================================
SCRIPT_NAME="ExternalDNS (AWS) Helm Chart Upgrade Script"  # ┐
HELM_REPO_NAME="external-dns"                               # │
HELM_REPO_URL="..."                                         # │ ★ user-owned (CONFIG block)
HELM_CHART="external-dns/external-dns"                      # │   sync preserves this
CHANGELOG_URL="..."                                         # │
CHART_TYPE="external"                                       # ┘
# ============================================================

CHART_DIR="$(cd "$(dirname "$0")" && pwd)"                  # ┐
BACKUP_DIR="$CHART_DIR/backup"                               # │
...                                                          # │ ★ canonical-owned
[main flow]                                                  # │   sync --apply overwrites this
...                                                          # │
echo " Upgrade complete!"                                    # ┘
```

- **CONFIG block** (between the first three `# ===` markers) — per-chart values, manually edited
- **Body** (after the third `# ===`) — shared by all charts, propagated from the canonical

`sync.sh --apply` leaves the CONFIG block alone and replaces the body with the
canonical's body.

<br/>

## Marker structure

Every `upgrade.sh` and every canonical use the same 3-marker layout:

```bash
# ============================================================  ← marker 1: doc start
# Configuration (per-chart, sync-managed body below)
# ============================================================  ← marker 2: doc end / vars start
SCRIPT_NAME=...
HELM_REPO_NAME=...
...
# ============================================================  ← marker 3: vars end / body start
CHART_DIR="$(cd ...)"
...
```

- **CONFIG block** = markers 1..3 (inclusive)
- **body** = everything after marker 3

<br/>

## Currently managed charts

| Template | Chart | Notes |
|---|---|---|
| `external-standard` | `aws/external-dns` | helm repo chart `external-dns/external-dns` via helmfile |
| `external-standard` | `aws/gitlab-runner-aws` | helm repo chart `gitlab/gitlab-runner` via helmfile |
| `external-standard` | `gcp/external-dns` | helm repo chart `external-dns/external-dns` via helmfile |

Everything else (`aws/eks-fargate-use-*`, `gcp/gke-use-*`, `gcp/haproxy`,
`onpremise/ke-use-*`) is a **local** chart whose `Chart.yaml` lives in this repo
and is not upgraded via the helm repo flow, so those do not have an
`upgrade.sh`.

<br/>

## Canonical variants

### 1. `external-standard.sh` — external helm repo chart (most common)

- **Use when**: a chart is pulled from a helm repo and deployed via helmfile
- **Flow**: 7 steps (current → fetch latest → download → diff Chart →
  diff values → check breaking → apply + backup)
- **Used by**: the 3 charts listed above

### 2. `external-with-image-tag.sh` — external + automatic image-tag bump

- **Use when**: same as external-standard, but `values/*.yaml` has
  `tag: vX.Y.Z` that must track the chart's `appVersion`
- **Extra step**: rewrites `tag:` fields in values files at the end of the
  main flow

### 3. `local-with-templates.sh` — local chart + custom template preservation

- **Use when**: `Chart.yaml` and `templates/` live in the repo directly, and
  after fetching an upstream chart you must preserve your own custom
  templates (e.g. `pv.yaml`, `pvc.yaml`)
- **Modes** (selected in CONFIG):
  - **helm repo mode** (default): set `HELM_REPO_*`, leave `CHART_GIT_REPO` empty
  - **git source mode**: set `CHART_GIT_REPO` and `CHART_GIT_PATH` — the
    script runs `git ls-remote --tags` for latest semver and `git clone` to
    fetch the chart (used for charts not published on any helm repo)

### 4. `local-cr-version.sh` — local chart (CR wrapper) + version-field tracking

- **Use when**: `templates/` contains Custom Resource YAML and the component
  version is tracked in a values field (e.g. `version: 9.0.0`). No upstream
  Helm chart exists — we are the sole owner
- **Supported feeds**: `elastic-artifacts`, `github-releases`, `docker-hub-tags`
- **Safety**: verifies the target version's container image exists in the
  registry before applying; detects downgrades during `--rollback` and
  optionally orchestrates the operator-webhook bounce

### 5. `ansible-github-release.sh` — Ansible-deployed + GitHub Releases feed

- **Use when**: the component is deployed by Ansible (not Helm) and its
  version lives in a single YAML field (e.g. `ansible/group_vars/all.yml`),
  with upstream on GitHub Releases
- **No helm concepts**: no `Chart.yaml`, no `helmfile.yaml`, no `values/`

<br/>

## sync.sh usage

Run `./scripts/upgrade-sync/sync.sh --help` for the full command list.

### `--status` — inventory

```bash
./scripts/upgrade-sync/sync.sh --status
```

Prints managed files grouped by template + unmanaged chart directories
(`Chart.yaml` present but no `upgrade.sh`).

### `--check` — drift verification (CI-friendly)

```bash
./scripts/upgrade-sync/sync.sh --check
```

Byte-for-byte compare every managed file with its canonical. Non-zero exit
on drift. Hook this into CI or a pre-commit.

### `--apply` — propagate canonical changes

```bash
# working tree must be clean (safety guard)
./scripts/upgrade-sync/sync.sh --apply

# force through a dirty tree
./scripts/upgrade-sync/sync.sh --apply --force
```

For every file:
1. read the template name from the header
2. extract the CONFIG block from the target
3. extract the body from the canonical
4. write the combined result and ensure the file is executable

### `--print-expected <file>` — single-file preview

```bash
./scripts/upgrade-sync/sync.sh --print-expected aws/external-dns/upgrade.sh \
  | diff - aws/external-dns/upgrade.sh
```

### `--insert-headers` — one-time migration helper

Adds `# upgrade-template: <name>` on the second line of any `upgrade.sh`
missing it. Template type is auto-detected from file contents. Idempotent.

<br/>

## check-versions.sh usage

Read-only survey of upstream latest versions across every managed chart,
so you can see at a glance which ones have upgrades available before running
`./upgrade.sh --dry-run` individually.

```bash
./scripts/upgrade-sync/check-versions.sh               # full table
./scripts/upgrade-sync/check-versions.sh --updates-only  # only UPDATE rows
./scripts/upgrade-sync/check-versions.sh --only external-dns
./scripts/upgrade-sync/check-versions.sh --no-update   # skip `helm repo update`
```

| Template | Current | Latest |
|---|---|---|
| `external-standard` / `external-with-image-tag` | `Chart.yaml` version | `helm search repo` top entry |
| `local-with-templates` (helm mode) | `Chart.yaml` version | `helm search repo` top entry |
| `local-with-templates` (git mode) | `Chart.yaml` version | `git ls-remote --tags` latest semver |
| `local-cr-version` | values file `<VERSION_KEY>` | `VERSION_SOURCE` feed (+ optional `MAJOR_PIN`) |
| `ansible-github-release` | values file `<VERSION_KEY>` | GitHub Releases API |

STATUS column: `OK` (current == latest), `UPDATE` (newer upstream exists),
`ERROR` (lookup failed, details on the next line).

Exit code: `0` on success (regardless of UPDATE count), `1` if any row errored.

<br/>

## manage-backups.sh usage

Each chart's `upgrade.sh` writes a snapshot to `<chart>/backup/<TIMESTAMP>/`
on every run. Backups accumulate over time, so this tool bulk-surveys and
prunes them.

```bash
./scripts/upgrade-sync/manage-backups.sh --list                  # per-chart table
./scripts/upgrade-sync/manage-backups.sh --total-size            # disk summary
./scripts/upgrade-sync/manage-backups.sh --cleanup               # keep latest 5 per chart (default)
./scripts/upgrade-sync/manage-backups.sh --cleanup --keep 1      # keep latest 1 per chart
./scripts/upgrade-sync/manage-backups.sh --purge                 # delete all (type 'PURGE' to confirm)
```

**Retention policy**: each chart keeps the most recent `KEEP_BACKUPS` (default
5) backups. The canonical's `auto_prune_backups` runs automatically at the
end of a successful `upgrade.sh`, so this tool is for ad-hoc cleanup /
disk monitoring.

<br/>

## Adding a new chart

### Case 1: external helm repo chart

```bash
# 1. copy the canonical into the chart directory
cp scripts/upgrade-sync/templates/external-standard.sh path/to/chart/upgrade.sh
chmod +x path/to/chart/upgrade.sh

# 2. edit the CONFIG block — replace every __PLACEHOLDER__
vim path/to/chart/upgrade.sh
```

Fields to set:
```bash
SCRIPT_NAME="<Chart Name> Helm Chart Upgrade Script"
HELM_REPO_NAME="<helm repo shortname>"
HELM_REPO_URL="<helm repo URL>"
HELM_CHART="<repo>/<chart>"
CHANGELOG_URL="<upstream changelog URL>"
CHART_TYPE="external"
```

```bash
# 3. verify and dry-run
./scripts/upgrade-sync/sync.sh --check
cd path/to/chart && ./upgrade.sh --dry-run
```

### Case 2: local chart + custom templates

Same as Case 1 but copy `local-with-templates.sh` instead, and additionally
set `CUSTOM_TEMPLATES=(...)` and optionally `CUSTOM_POD_PATCH='...'`.

### Case 3: git-source local chart (no helm repo)

Copy `local-with-templates.sh`, leave `HELM_REPO_*` empty, and set
`CHART_GIT_REPO` + `CHART_GIT_PATH` instead.

<br/>

## Troubleshooting

### `sync.sh: command not found` or `Permission denied`

```bash
chmod +x scripts/upgrade-sync/sync.sh
```

### `ERROR: <file> has no '# upgrade-template:' header on line 2`

One-time migration:
```bash
./scripts/upgrade-sync/sync.sh --insert-headers
```

### `ERROR: working tree is dirty. Commit or stash before --apply.`

Safety guard. Either commit first or re-run with `--force`.

### `--check` reports drift on every file

Likely causes:
1. You edited the canonical but haven't run `--apply` yet
2. The canonical's marker structure is broken (`# ===` lines not exactly 3)
3. `detect_template` misclassified a file — check its `# upgrade-template:` header

### `--check` reports drift on exactly one file

```bash
./scripts/upgrade-sync/sync.sh --print-expected <file> | diff - <file>
```

If the diff is an intentional change, fold it into the canonical and
`--apply`. If it's an accidental manual edit, `--apply` reverts it.

<br/>

## Compatibility

- **macOS bash 3.2** (default) — no `declare -A` or other bash 4+ features
- **Linux bash 4+** — works
- **sed** — uses a portable pattern that works with both BSD sed (macOS) and
  GNU sed (Linux); the canonical body writes via `sed ... > tmp && mv` rather
  than `sed -i ''`
- **awk** — only portable POSIX awk features
- **find** — `-not -path '...'` is portable between BSD and GNU find

<br/>

## Safety features

- **`--apply` git guard**: aborts on a dirty working tree so a sync never
  silently overwrites unrelated in-progress edits. `--force` to override.
- **Header-based dispatch**: every managed file declares its canonical in
  its 2-line header, so sync cannot pick the wrong template silently.
- **Byte-wise `--check`**: any byte-level divergence counts as drift.

<br/>

## FAQ

**Q: I added code to the body of my `upgrade.sh` and the next sync wiped it.**

Expected. The body is canonical-owned; `--apply` overwrites it. To add new
behavior, either:
1. edit the canonical itself (applies to every chart sharing it), or
2. gate the new behavior on a CONFIG variable so each chart can opt in
   (CONFIG is user-owned and sync preserves it).

**Q: My chart needs an extra placeholder the canonical doesn't have.**

1. Add it to the canonical's CONFIG placeholders (e.g. `EXTRA_DIR="__EXTRA_DIR__"`)
2. Use it in the canonical's body
3. Set the real value in the chart's CONFIG block

Charts that don't need it can leave the value empty.

**Q: What about `backup/` directories?**

`find_managed_files` excludes `*/backup/*`, so each chart's backup dir is
invisible to sync.

**Q: How do I wire this into CI?**

Add a single step that runs `./scripts/upgrade-sync/sync.sh --check`. Non-zero
exit fails the build when drift appears.
