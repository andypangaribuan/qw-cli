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

## Build

If your host have dart sdk

```shell
$ git clone https://github.com/andypangaribuan/qw-cli.git
$ cd qw-cli

# run without build
$ dart bin/qw_cli.dart

# build
$ mkdir -p out
$ dart compile exe bin/main.dart -o out/qw

$ mv out/qw /usr/local/bin
```

Using docker

```shell
# clone the project
$ git clone https://github.com/andypangaribuan/qw-cli.git

# build inside docker
$ docker run --rm -v ./qw-cli:/qw-cli dart:2.17.6 bash -c '\
  rm -rf /qw-cli/qw && \
  cp -R /qw-cli /build-qw-cli && \
  cd /build-qw-cli && \
  dart pub get && \
  mkdir -p out && \
  dart compile exe bin/main.dart -o out/qw && \
  cp out/qw /qw-cli/qw'

# move the qw file
$ sudo mv ./qw-cli/qw /usr/local/bin
# move for everyone
$ sudo mv ./qw-cli/qw /usr/bin
```

## Usage

```shell
# access the command
$ qw
```

Features:

- docker > image | ps
- workbench > psql-convert

## License

See [`LICENSE`](./LICENSE)
