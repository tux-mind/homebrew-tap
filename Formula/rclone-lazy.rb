class RcloneLazy < Formula
  desc "Rclone fork with --vfs-lazy-dir-read for large flat S3 buckets"
  homepage "https://github.com/tux-mind/rclone"
  url "https://github.com/tux-mind/rclone/archive/dffc001d4d484a764145c09fa7aa39cc60978927.tar.gz"
  version "1.73.4-lazy"
  sha256 "c6e0abe08ba3d7f645df1c4bcb93ea97195d2b61181c15414c267df0b759d5fe"
  license "MIT"

  depends_on "go" => :build

  conflicts_with "rclone", because: "both install a `rclone` binary"

  def install
    ldflags = %W[
      -s -w
      -X github.com/rclone/rclone/fs.Version=v#{version}
    ]
    tags = "brew" if OS.mac?
    system "go", "build", *std_go_args(ldflags:, tags:, output: bin/"rclone")
    man1.install "rclone.1"
  end

  def caveats
    <<~EOS
      This build includes --vfs-lazy-dir-read: single-file stat uses HeadObject
      (e.g. S3) instead of listing the entire directory. Useful for buckets with
      millions of flat objects.

      Use nfsmount for compatibility with fuse-t (no FUSE kext required):

        rclone nfsmount remote:bucket /mnt/point \\
          --vfs-lazy-dir-read \\
          --vfs-case-insensitive=false \\
          --no-unicode-normalization \\
          --read-only

      Note: --vfs-case-insensitive defaults to true on macOS and must be
      explicitly set to false to activate lazy stat.
    EOS
  end

  test do
    system bin/"rclone", "version"
  end
end
