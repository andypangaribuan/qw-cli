/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import "fmt"

func K8S(args []string) {
	commands := `
available command:
- pod : show pod access
	`

	if len(args) == 0 {
		fmt.Printf("invalid command\n%v\n", commands)
		return
	}

	switch args[0] {
	case "pod":
		pod(args[1:])

	default:
		fmt.Printf("invalid command\n%v\n", commands)
		return
	}
}
