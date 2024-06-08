/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import (
	"qw/util"
)

func K8S(args []string) {
	util.ToPath(args, `
		- pod : show pod access`,
		map[string]func(args []string){
			"pod": pod,
		})
}
