# Binary formula: it installs the release archives built by TRX64's own CI rather than
# compiling on the user's machine. A source build would mean ~20 minutes of 433 crates,
# most of it a bundled DuckDB C++ amalgamation, for every install and every upgrade.
#
# Homebrew's core repository does not accept binary formulae, which is one of the reasons
# this lives in a tap. The other is that TRX64 vendors reSID and bundles DuckDB on purpose,
# so the binaries run without any further installation — exactly what core would ask us to
# undo.
#
# A pleasant side effect on macOS: Homebrew fetches with curl, and curl attaches no
# com.apple.quarantine. So these binaries start without notarization and without the
# `xattr -d` dance a browser download would need.
class Trx64 < Formula
  desc "Commodore 64 runtime: WebSocket daemon with A/V and monitor, terminal cockpit"
  homepage "https://github.com/Jondalar/TRX64"
  version "0.12.2"
  license "GPL-3.0-or-later"

  # Every macOS and Linux target the CI publishes: arm64 and x86_64 on both.
  on_macos do
    on_arm do
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.2/trx64-0.12.2-macos-arm64.tar.gz"
      sha256 "fb17e38d75846413a4beca1c7827cfcd249bd5be0f838bac1fb2ae3108319c90"
    end
    on_intel do
      # Cross-built on Apple silicon with --target x86_64-apple-darwin.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.2/trx64-0.12.2-macos-x86_64.tar.gz"
      sha256 "f3a73feecd55c34eefed75c5c65403da7370691e958c632ecc06dc7cbebd5870"
    end
  end

  on_linux do
    on_intel do
      # Built in a rust:bookworm container; the binary's own symbols put the floor at
      # glibc 2.34, so Ubuntu 22.04, Debian 12, RHEL 9 and newer.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.2/trx64-0.12.2-linux-x86_64.tar.gz"
      sha256 "bb9e5d13626c77ea137537f6d6a732aa7c674c30620b34808875d2552b044d85"
    end
    on_arm do
      # Same rust:bookworm container and glibc 2.34 floor as x86_64, on an arm64 runner.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.2/trx64-0.12.2-linux-arm64.tar.gz"
      sha256 "139e30756c2b8b54edc92b6c911f8b3d636970307d5a3ec6eb5fb47b3e2cb8a4"
    end
  end

  def install
    bin.install "trx64cli", "trx64-daemon"
  end

  def caveats
    <<~EOS
      TRX64 ships no C64 ROMs and never will — they are Commodore's property, not ours
      to distribute. Six files, ~68 KB, normally a copy of a set you already own.

      Point the binaries at yours, in this order of preference:

        trx64cli --rom-dir /path/to/roms          per invocation
        export C64RE_ROOT=/path/to/c64re          then <that>/resources/roms is used

      Do NOT rely on a roms/ folder next to the executable here: that path lives inside
      the Homebrew Cellar and a `brew upgrade` replaces it.

      The daemon speaks one WebSocket (default port 4340) carrying video, audio and a
      JSON-RPC monitor:

        trx64-daemon --port 4340
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/trx64cli --version")
    assert_match version.to_s, shell_output("#{bin}/trx64-daemon --version")
  end
end
