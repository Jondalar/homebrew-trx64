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
  version "0.12.9"
  license "GPL-3.0-or-later"

  # Every macOS and Linux target the CI publishes: arm64 and x86_64 on both.
  on_macos do
    on_arm do
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.9/trx64-0.12.9-macos-arm64.tar.gz"
      sha256 "55ac1fc156801756c47b448edc0ed3021760c00461972f9d7d648140190624f2"
    end
    on_intel do
      # Cross-built on Apple silicon with --target x86_64-apple-darwin.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.9/trx64-0.12.9-macos-x86_64.tar.gz"
      sha256 "574b454b4ca1c171ab6078873644033a0adbd16f2d35e69d3884a036f0bf7b99"
    end
  end

  on_linux do
    on_intel do
      # Built in a rust:bookworm container; the binary's own symbols put the floor at
      # glibc 2.34, so Ubuntu 22.04, Debian 12, RHEL 9 and newer.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.9/trx64-0.12.9-linux-x86_64.tar.gz"
      sha256 "e7e63f0da25633e3792d73c9f8a42554537dbd05fbf212b9364fd1d708e66145"
    end
    on_arm do
      # Same rust:bookworm container and glibc 2.34 floor as x86_64, on an arm64 runner.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.12.9/trx64-0.12.9-linux-arm64.tar.gz"
      sha256 "d4c07a0e45346aad4b606e21d5d4cf9ef2d402012a6e9ce51d95f6c0454f4f27"
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
