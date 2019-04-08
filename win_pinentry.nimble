# Package

version       = "0.1.0"
author        = "Samantha Demi"
description   = "pinentry-auto but via windows for WSL envs"
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["win_pinentry"]
skipDirs      = @["win-pinentry"]
skipFiles     = @["win-pinentry.sln"]
skipExt       = @["cpp", "sln"]

# Dependencies

requires "nim >= 0.19.4"
requires "winim"
