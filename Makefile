all: help

help:
	@echo "→ build"

build:
	@dart compile exe bin/qw_cli.dart -o out/qw
