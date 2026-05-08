class RcloneLazy < Formula
  desc "Rclone fork with --vfs-lazy-dir-read for large flat S3 buckets"
  homepage "https://github.com/tux-mind/rclone"
  url "https://github.com/tux-mind/rclone/archive/4f280e51e33e25387ccfc6c5d0335eead7434ce5.tar.gz"
  version "1.74.0-lazy"
  sha256 "71a546b53ddc193da7fd9eeaeb84bfc972b01edad4190808fa8f63ee0eb033ea"
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

      nfsmount doesn't work for some reason.

      Use serve nfs + mount_nfs for macOS (no FUSE kext required):

        rclone serve nfs remote:bucket --addr 127.0.0.1:PORT \\
          --vfs-lazy-dir-read \\
          --vfs-case-insensitive=false \\
          --no-unicode-normalization \\
          --vfs-cache-mode full \\
          --vfs-cache-max-size 2G \\
          --read-only

      Note: --vfs-case-insensitive defaults to true on macOS and must be
      explicitly set to false to activate lazy stat.
    EOS
  end

  test do
    system bin/"rclone", "version"
  end
end
