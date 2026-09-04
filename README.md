# homebrew-skylark

A [Homebrew](https://brew.sh) tap for [Skylark](https://github.com/jjromano/skylark),
a native macOS menu-bar dictation app. Hold a key, speak, and text lands at your
cursor in whatever app you were typing in.

## Install

```sh
brew install --HEAD jjromano/skylark/skylark
skylark-setup
```

`skylark-setup` is a separate step on purpose. Skylark needs a code-signing
certificate in the System keychain, which requires your password, and Homebrew
must never run as root or prompt for one mid-install. So `brew install` builds
the app and `skylark-setup` does the privileged part: create the certificate,
sign the app with it, install it into `/Applications`, and launch it.

That certificate is what makes your Microphone, Accessibility and Input
Monitoring permissions survive future upgrades instead of being asked for again
every time.

## Update

```sh
brew upgrade skylark && skylark-setup
```

## Why this builds from source

There is no bottle and no cask, deliberately. Both would mean downloading a
prebuilt binary, and macOS Gatekeeper refuses those unless they are Developer ID
signed and notarized by Apple, which requires a paid Apple Developer Program
membership. An app you compile on your own Mac never gets a quarantine flag, so
building from source is what makes a free install work at all.

The first build takes a few minutes.

## Requirements

- Apple Silicon Mac
- macOS 26 or later
- Xcode Command Line Tools (`xcode-select --install`)
- About 1.2 GB free for the speech models, downloaded on first launch

## License

Skylark is MIT. This tap is MIT.
