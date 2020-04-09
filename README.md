<p align="center">
  <img src=".github/Logo.png" width="480" max-width="90%" alt="spasibo" />
</p>

```html
<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <a href="https://twitter.com/iosartem">
        <img src="https://img.shields.io/badge/twitter-@iosartem-blue.svg?style=flat" alt="Twitter: @iosartem" />
    </a>
</p>
```

## Features

- Based on Github Sponsors
- Carthage and Swift Package Manager support

## Using

Run `spasibo` in project folder and see which of your dependencies support donations. Spasibo scans *Cartfile* and *Package.swift* files, checks that dependencies have *FUNDING.yml* and displays a list of funding sources.


Run `spasibo --help` to see available commands:

```bash
USAGE: spasibo [--path <path>]

OPTIONS:
  -p, --path <path>       The path to project directory.
  -h, --help              Show help information.
```


## Installing

- [Homebrew](https://brew.sh) (recommended): `brew install artemnovichkov/projects/spasibo`
- [Mint](https://github.com/yonaskolb/Mint): `mint run artemnovichkov/spasibo`
- From source: `make install`

## Author

Artem Novichkov, novichkoff93@gmail.com

## License

The project is available under the MIT license. See the LICENSE file for more info.

