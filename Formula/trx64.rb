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
  desc "Commodore 64 runtime: WebSocket daemon with A/V and monitor, plus terminal cockpit"
  homepage "https://github.com/Jondalar/TRX64"
  version "0.3.2"
  license "GPL-3.0-or-later"

  # Only the two targets the CI publishes. Homebrew refuses the install with a clear
  # message on anything else (Intel Macs, arm64 Linux) rather than fetching the wrong file.
  on_macos do
    on_arm do
      url "https://github.com/Jondalar/TRX64/releases/download/v0.3.2/trx64-0.3.2-macos-arm64.tar.gz"
      sha256 "6b4dcda4dcd9bf568e0c6a5851d914079484ed6659fe2dadef2b4f6eb44a1c1f"
    end
  end

  on_linux do
    on_intel do
      # Built in a rust:bookworm container; the binary's own symbols put the floor at
      # glibc 2.29, so Ubuntu 20.04, Debian 11 and newer.
      url "https://github.com/Jondalar/TRX64/releases/download/v0.3.2/trx64-0.3.2-linux-x86_64.tar.gz"
      sha256 "40aeb85757218c2ef92d067a26fef090aaa73b485ed872ae0012044b4efc23bf"
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
