# tux-mind/homebrew-tap

Personal [Homebrew tap](https://docs.brew.sh/Taps) with formulae and casks
for custom builds, forks, and pre-release apps.

## Quick install

Everything in this tap can be installed without running `brew tap` first —
Homebrew resolves the `user/repo/formula`/`user/repo/cask` shorthand
automatically:

```sh
brew install tux-mind/tap/<formula-or-cask>
```

To add the tap permanently (so `brew upgrade` tracks all formulae here):

```sh
brew tap tux-mind/tap
```

---

## Formulae

### `rclone-lazy`

A fork of [rclone](https://rclone.org) — [tux-mind/rclone](https://github.com/tux-mind/rclone) —
with `--vfs-lazy-dir-read`, which avoids full directory listings when looking
up single files on large flat remotes (e.g. S3 buckets with millions of
objects).

#### Install

```sh
brew install tux-mind/tap/rclone-lazy
```

Installs as `rclone-lazy` — no conflict with the official `rclone` formula.

#### Usage

```sh
rclone-lazy nfsmount s3:my-huge-bucket /mnt/data \
  --vfs-lazy-dir-read \
  --vfs-case-insensitive=false \
  --no-unicode-normalization \
  --read-only
```

> **macOS / Windows note:** `--vfs-case-insensitive` defaults to `true` on
> these platforms and **must** be set to `false` to activate lazy stat.
> `--no-unicode-normalization` must also be set (it is off by default
> everywhere).

#### How it works

With `--vfs-lazy-dir-read`, a single-file `stat` or `Lookup` call resolves
the name via a direct `HeadObject` (S3) instead of listing the entire parent
directory. This reduces an O(N) `ListObjectsV2` scan to a single O(1)
request.

`ReadDirAll` (`ls`, `find`, etc.) still performs a full listing — only
single-file stat lookups benefit.

---

## Casks

### `finicky@alpha`

A pre-release build of [Finicky](https://github.com/johnste/finicky), tracking
the latest `-alpha` tag published upstream (currently `4.4.0-alpha`). Finicky
is not forked here — this cask simply makes the unstable build installable
via Homebrew ahead of a stable release.

#### Install

```sh
brew install tux-mind/tap/finicky@alpha
```

> **Note:** This cask shares Finicky's bundle identifier and preferences
> file with the official `finicky` cask from `homebrew/cask`, so the two
> **cannot** be installed at the same time (`conflicts_with` enforces this).
> Expect instability — this tracks upstream alpha tags, not stable releases.

---

## Updating a formula

When you want to pin a formula to a new commit or release:

```sh
# 1. Compute the SHA256 of the new source tarball
curl -sL https://github.com/tux-mind/<repo>/archive/<COMMIT_OR_TAG>.tar.gz \
  | shasum -a 256

# 2. Edit the formula
$EDITOR Formula/<formula>.rb   # update url, version, sha256

# 3. Audit locally
brew audit --formula tux-mind/tap/<formula>

# 4. Commit and push
git commit -am "<formula>: update to <version>"
git push
```

Users get the update on their next `brew upgrade`.

## Updating a cask

When a new upstream release needs to be picked up manually (or to verify
what `brew livecheck` would do automatically):

```sh
# 1. Find the SHA256 of the new release asset
curl -sL https://github.com/<owner>/<repo>/releases/download/<TAG>/<asset> \
  | shasum -a 256

# 2. Edit the cask
$EDITOR Casks/<cask>.rb   # update version, sha256

# 3. Audit locally
brew audit --cask tux-mind/tap/<cask>

# 4. Commit and push
git commit -am "<cask>: update to <version>"
git push
```

Casks with a `livecheck` block (like `finicky@alpha`) can also be checked
directly with `brew livecheck tux-mind/tap/<cask>`.
