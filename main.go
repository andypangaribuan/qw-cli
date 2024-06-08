/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package main

import (
	"os"
	"qw/k8s"
	"strings"

	"qw/util"

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

	util.ToPath(args, `
		- k8s : kubernetes client`,
		map[string]func(args []string){
			"k8s": k8s.K8S,
		})
}
