cask "finicky@alpha" do
  version "4.4.0-alpha"
  sha256 "df6639bf02d5c4c3cf16d117e55339d55191d55dd79c89a78808c6538f7c39a9"

  url "https://github.com/johnste/finicky/releases/download/v#{version}/Finicky.dmg"
  name "Finicky"
  desc "Utility for customizing which browser to start (pre-release build)"
  homepage "https://github.com/johnste/finicky"

  livecheck do
    url "https://github.com/johnste/finicky/releases"
    regex(/^v?(\d+(?:\.\d+)+-alpha)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"]

        release["tag_name"][regex, 1]
      end
    end
  end

  conflicts_with cask: "finicky"
  depends_on macos: :monterey

  app "Finicky.app"

  zap trash: "~/Library/Preferences/se.johnste.finicky.plist"

  caveats <<~EOS
    This is a pre-release (alpha) build of Finicky, tracking the latest
    "-alpha" tag published upstream. It is not stable and may change or
    disappear at any time.

    It shares its bundle identifier and preferences with the official
    `finicky` cask, so the two cannot be installed at the same time.

    Release notes: https://github.com/johnste/finicky/releases/tag/v#{version}
  EOS
end
