/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

func K8S(args []string) {
	if len(args) == 0 {
		invalid()
		return
	}

	switch args[0] {
	case "pod":
		pod(args[1:])

	default:
		invalid()
		return
	}
}
