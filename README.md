<p align="center">
  <img width="100" height="100" src="res/SpmImageTycoon_animated.svg?raw=true" />
</p>

# Installer for SpmImage Tycoon

[![Build Status](https://github.com/alexriss/SpmImageTycoonInstaller.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/alexriss/SpmImageTycoonInstaller.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/alexriss/SpmImageTycoonInstaller.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/alexriss/SpmImageTycoonInstaller.jl)

Installer for the world-famous [SpmImage Tycoon](https://github.com/alexriss/SpmImageTycoon.jl) - a cross-platform app to manage and edit scanning probe microscopy images and spectra.

## Screenshot

![screenshot](demo/screenshot_install.png?raw=true)

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

## Cite

If you use [SpmImage Tycoon](https://github.com/alexriss/SpmImageTycoon.jl) for your scientific work, please consider citing it:

[![DOI](https://joss.theoj.org/papers/10.21105/joss.04644/status.svg)](https://doi.org/10.21105/joss.04644)

```bibtex
@article{Riss_JOSS_2022,
  doi = {10.21105/joss.04644},
  url = {https://doi.org/10.21105/joss.04644},
  year = {2022},
  publisher = {The Open Journal},
  volume = {7},
  number = {77},
  pages = {4644},
  author = {Alexander Riss},
  title = {SpmImage Tycoon: Organize and analyze scanning probe microscopy data},
  journal = {Journal of Open Source Software}
}
```

## Tips and tricks

To get rid of the console window under Windows, you can install [AutoHotkey](https://www.autohotkey.com/).
This will be automatically detected and extra Start Menu and Desktop will be set up to suppress the console window.

<a href="https://twitter.com/00alexx">Follow me on twitter</a> for updates and more information about this project: 
<a href="https://twitter.com/00alexx"><img src="https://img.shields.io/twitter/follow/00alexx?style=social" alt="Twitter"></a>

## Related projects

- [SpmImageTycoon.jl](https://github.com/alexriss/SpmImageTycoon.jl): App to organize SPM images and spectra.
- [SpmImages.jl](https://github.com/alexriss/SpmImages.jl): Julia library to read and display SPM images.
- [SpmSpectroscopy.jl](https://github.com/alexriss/SpmSpectroscopy.jl): Julia library to read and analyze SPM spectra.
- [SpmGrids.jl](https://github.com/alexriss/SpmGrids.jl): Julia library to read and analyze SPM grid spectroscopy.
- [imag*ex*](https://github.com/alexriss/imagex): Python scripts to analyze scanning probe images.
- [grid*ex*](https://github.com/alexriss/gridex): Python scripts to analyze 3D grid data.
