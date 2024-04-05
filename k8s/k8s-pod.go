/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

func pod(args []string) {
	if len(args) == 0 {
		invalid()
		return
	}

	switch args[0] {
	case "show":
		podShow(args[1:])

	default:
		invalid()
		return
	}
}
