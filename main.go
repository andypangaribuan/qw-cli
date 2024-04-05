/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package main

import (
	"fmt"
	"os"
	"qw/k8s"
	"strings"

	_ "github.com/andypangaribuan/gmod"
)

func main() {
	args := os.Args
	if len(args) > 0 {
		args = args[1:]
	}

	for i, arg := range args {
		args[i] = strings.TrimSpace(arg)
	}

	if len(args) == 0 {
		mainInvalid()
		return
	}

	switch args[0] {
	case "k8s":
		k8s.K8S(args[1:])

	default:
		mainInvalid()
		return
	}
}

func mainInvalid() {
	fmt.Printf("unknown command\n")
}
