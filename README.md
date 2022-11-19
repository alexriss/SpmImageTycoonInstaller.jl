<p align="center">
  <img width="100" height="100" src="res/SpmImageTycoon_animated.svg?raw=true" />
</p>

# Installer for SpmImage Tycoon

[![Build Status](https://github.com/alexriss/SpmImageTycoonInstaller.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/alexriss/SpmImageTycoonInstaller.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/alexriss/SpmImageTycoonInstaller.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/alexriss/SpmImageTycoonInstaller.jl)

Installer for the world-famous [SpmImage Tycoon](https://github.com/alexriss/SpmImageTycoon.jl) - a cross-platform app to manage and edit scanning probe microscopy images and spectra.

![demo](demo/screenshot_install.png?raw=true)

## Use

_Please only use the app if you read the disclaimer on the [SpmImage Tycoon project page](https://github.com/alexriss/SpmImageTycoon.jl)._

Usage is simple:

1. Install [Julia](https://julialang.org/)
2. Start Julia and type the following two commands:
```julia
using Pkg
Pkg.add("SpmImageTycoonInstaller")
using SpmImageTycoonInstaller
install()
```
This will install a compiled version of [SpmImage Tycoon](https://github.com/alexriss/SpmImageTycoon.jl).
The installation will typically take 10 to 20 minutes and take up around 1 GB of space.
The same procedure can be used to update to the latest version.

The compiled version will start fast, even on the first run.

_Tested on Windows and Linux so far. If you are a Apple user, give it a try._

## Tips and tricks

To get rid of the console window under Windows, you can install [AutoHotkey](https://www.autohotkey.com/).
This will be automatically detected and extra Start Menu and Desktop will be set up to suppress the console window.
