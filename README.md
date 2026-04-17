# tux-mind/homebrew-tap

Personal [Homebrew tap](https://docs.brew.sh/Taps) with formulae for custom
builds and forks.

## Quick install

All formulae in this tap can be installed without running `brew tap` first —
Homebrew resolves the `user/repo/formula` shorthand automatically:

```sh
brew install tux-mind/tap/<formula>
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
