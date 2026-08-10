# homebrew-trx64

Homebrew tap for [TRX64](https://github.com/Jondalar/TRX64) — a Commodore 64 runtime.

```sh
brew tap Jondalar/trx64
brew install trx64
```

macOS on Apple Silicon, and Linux on x86_64 (glibc 2.29+, so Ubuntu 20.04 / Debian 11
and newer). Installs two binaries:

| | |
|---|---|
| `trx64-daemon` | runs a machine, streams video + audio + a JSON-RPC monitor over one WebSocket |
| `trx64cli` | terminal cockpit that drives it, with an optional native emulator window |

## ROMs are not included

They are Commodore's property. Supply your own with `--rom-dir <path>`, or set
`C64RE_ROOT=<dir>` so `<dir>/resources/roms` holds them. `brew info trx64` repeats this.

## Why a tap and not homebrew/core

This is a binary formula — it installs archives built by TRX64's CI instead of compiling
433 crates (most of the time being a bundled DuckDB C++ amalgamation) on every machine.
Core does not accept binary formulae, and would want the vendored reSID and bundled DuckDB
replaced by brew dependencies, which is precisely what makes the released binaries run
without further installation.

On macOS it also sidesteps Gatekeeper entirely: Homebrew fetches with curl, which attaches
no `com.apple.quarantine`, so nothing needs notarizing or `xattr`-ing.

## Updating the formula for a new release

The version, both URLs and both `sha256` lines come straight from the release assets:

```sh
gh release download vX.Y.Z -R Jondalar/TRX64 -p '*.sha256' -D /tmp/rel
cat /tmp/rel/*.sha256
```
