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
curl -L https://github.com/andypangaribuan/qw-cli/releases/download/v1.0.2/qw -o qw
chmod +x qw
mv qw /usr/local/bin
```

## Build

If your host have dart sdk

```shell
git clone https://github.com/andypangaribuan/qw-cli.git
cd qw-cli

# run without build
dart bin/qw_cli.dart

# build
mkdir -p out
dart compile exe bin/main.dart -o out/qw
```

Using docker

```shell
docker run --rm -it dart:2.17.6 bash

# on host
docker cp qw-cli {CONTAINER ID}:/qw-cli

# on container
cd /qw-cli
dart pub get
mkdir -p out
dart compile exe bin/main.dart -o out/qw

# on host
docker cp {CONTAINER ID}:/qw-cli/out/qw ~/qw
mv ~/qw /usr/local/bin
```

## Usage

```shell
qw
```

Features:
- docker > image | ps
- workbench > psql-convert

## License

See [`LICENSE`](./LICENSE)
