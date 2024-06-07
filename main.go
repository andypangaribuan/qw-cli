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
	const commands = `
available commands:
- k8s : kubernetes client
`

	args := os.Args
	if len(args) > 0 {
		args = args[1:]
	}

	for i, arg := range args {
		args[i] = strings.TrimSpace(arg)
	}

	if len(args) == 0 {
		fmt.Printf("invalid command\n%v\n", commands)
		return
	}

	switch args[0] {
	case "k8s":
		k8s.K8S(args[1:])

	default:
		fmt.Printf("invalid command\n%v\n", commands)
		return
	}
}
