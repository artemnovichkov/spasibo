<p align="center">
  <img src=".github/Logo.png" alt="spasibo" />
</p>


<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
  <a href="https://brew.sh">
    <img src="https://img.shields.io/badge/homebrew-compatible-brightgreen.svg?style=flat" alt="Homebrew" />
  </a>
    <a href="https://github.com/yonaskolb/Mint">
    <img src="https://img.shields.io/badge/mint-compatible-brightgreen.svg?style=flat" alt="Mint" />
  </a>
    <a href="https://twitter.com/iosartem">
        <img src="https://img.shields.io/badge/twitter-@iosartem-blue.svg?style=flat" alt="Twitter: @iosartem" />
    </a>
</p>

> 'Spasibo' means 'thank you' in Russian.

**Spasibo** is a simple command-line tool to supporting open-source frameworks.

## Features

- Based on Github Sponsors
- [Community Health files](https://help.github.com/en/github/building-a-strong-community/creating-a-default-community-health-file) support
- Cocoapods, Carthage, and Swift Package Manager support

## Using

Run `spasibo` in project folder and see which of your dependencies support donations. Spasibo scans *Podfile.lock*, *Cartfile* and *Package.swift* files, checks that dependencies have [*FUNDING.yml*](https://help.github.com/en/github/administering-a-repository/displaying-a-sponsor-button-in-your-repository#about-funding-files) and displays a list of funding sources.


Run `spasibo --help` to see available commands:

```bash
OVERVIEW: 🙏 Support your favourite open source projects

USAGE: spasibo [--path <path>] [--verbose]

OPTIONS:
  -p, --path <path>       The path to project directory. (default: <current directory>)
  -v, --verbose           Print status updates while running. 
  --version               Show the version.
  -h, --help              Show help information.
```

## Installing

- [Homebrew](https://brew.sh) (recommended): `brew install artemnovichkov/projects/spasibo`
- [Mint](https://github.com/yonaskolb/Mint): `mint run artemnovichkov/spasibo`
- From source: `make install`

## Known issues

With some environments Spasibo may have a problems with Cocoapods. If you see `Fail to run pod spec cat` error, try to set PATH environment with you pod path. To do it, run:

```bash
$ which pod
path/to/your/pod
$ PATH=path/to/your/pod spasibo
```

If you know how to fix it properly, feel free to create a pull request or an issue with suggestion.

## Author

Artem Novichkov, novichkoff93@gmail.com

## License

The project is available under the MIT license. See the LICENSE file for more info.

