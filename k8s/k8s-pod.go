/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import "qw/util"

func pod(args []string) {
	util.ToPath(args, `
		- show : show all container, value: {deployment-name} {deployment-name} ..., opts: -n={namespace}`,
		map[string]func(args []string){
			"show": podShow,
		})
}
