<!--
pubspec.yaml
dev_dependencies:
  # dtg:
    # path: /Users/apangaribuan/repo/github/dtg
-->

# QW CLI

Cross-platform enhanced CLI tools for your daily needs

## Installing

```shell
# download the qw file
$ curl -L https://github.com/andypangaribuan/qw-cli/releases/download/v1.0.3/qw-darwin-arm64 -o qw
$ chmod +x qw
$ mv qw /usr/local/bin
```

## Usage

```shell
# access the command
$ qw
```

Features:

```shell
$ qw k8s pod show {-n} {deploy1...n}

val:
▶︎ deploy1...n : deployment name, you can use multiple deployment name, e.q.: clog pwatch

opt:
-n : namespace, e.q.: -n=central

```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/andypangaribuan/qw-cli/tags).

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [`issue`](https://github.com/andypangaribuan/qw-cli/issues).  
If you fixed a bug or implemented a feature, please send a [`pull request`](https://github.com/andypangaribuan/qw-cli/pulls).

## License

MIT License

Copyright (c) 2024 Andy Pangaribuan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.