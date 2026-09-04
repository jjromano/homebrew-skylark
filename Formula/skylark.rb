class Skylark < Formula
  desc "Native macOS menu-bar dictation: hold a key, speak, text lands at your cursor"
  homepage "https://github.com/jjromano/skylark"
  license "MIT"
  head "https://github.com/jjromano/skylark.git", branch: "main"

  # Source-build only, deliberately. A bottle (or a cask) would be a prebuilt
  # binary downloaded from the internet, and macOS Gatekeeper refuses those
  # unless they are Developer ID signed AND notarized by Apple, which needs a
  # paid Apple Developer Program membership. An app compiled on your own Mac
  # never gets a quarantine flag, so building from source is what makes a free,
  # unnotarized install work at all.

  depends_on arch: :arm64
  depends_on macos: :tahoe # macOS 26 — SpeechAnalyzer, FoundationModels, Swift 6.2

  def install
    # SwiftPM starts its own sandbox-exec to compile Package.swift, and `brew
    # install` is already running inside Homebrew's sandbox. The nested one is
    # refused ("sandbox_apply: Operation not permitted") and the build dies at
    # the manifest before compiling a line. bundle.sh forwards this through.
    ENV["SKYLARK_SWIFT_BUILD_FLAGS"] = "--disable-sandbox"

    # Skylark pins the Command Line Tools toolchain (Swift 6.2.x). On a Mac that
    # also has Xcode installed, `xcode-select` usually points at Xcode instead,
    # and its newer Swift produces a manifest the pinned tools reject. Prefer the
    # CLT when it is present; fall back to whatever is selected otherwise.
    ENV["DEVELOPER_DIR"] = "/Library/Developer/CommandLineTools" if
      File.directory?("/Library/Developer/CommandLineTools/usr/bin")

    # Build the signed .app bundle. bundle.sh signs with the local
    # "Skylark Dev Signing" identity when it exists and ad-hoc otherwise; either
    # way `skylark-setup` re-signs afterwards, which is what makes macOS
    # permission grants survive future upgrades.
    system "make", "app"

    prefix.install "dist/Skylark.app"

    # The privileged half of the install (System-keychain certificate,
    # /Applications) cannot run inside `brew install` — Homebrew must not run as
    # root or prompt for a password. Ship the scripts and let the user run them
    # once, deliberately.
    libexec.install "Scripts/make-cert.sh"
    bin.install "Scripts/brew-setup.sh" => "skylark-setup"

    # Dependency license texts. Building from source means Homebrew fetches
    # these from their own repositories rather than us redistributing their
    # binaries, but shipping the notices costs nothing and is required the
    # moment a binary is ever distributed.
    (prefix/"licenses").install "LICENSE" => "Skylark-MIT.txt"
    (prefix/"licenses").install "Vendor/LICENSE-llama.cpp.txt"
  end

  def caveats
    <<~EOS
      One more step — run this once to finish the install:

          skylark-setup

      It creates a local signing certificate (macOS will ask for your password),
      installs Skylark into /Applications, and launches it. The certificate is
      what lets your Microphone, Accessibility and Input Monitoring grants
      survive future upgrades instead of being asked for every time.

      Skylark is a MENU-BAR app. Look for the bird near the clock, not the Dock.

      To update:
          brew upgrade skylark && skylark-setup
    EOS
  end

  test do
    assert_predicate prefix/"Skylark.app/Contents/MacOS/Skylark", :executable?
    assert_match "com.jjromano.skylark",
                 shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' " \
                              "#{prefix}/Skylark.app/Contents/Info.plist")
  end
end
