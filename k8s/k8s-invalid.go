/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import "fmt"

func invalid() {
	fmt.Printf("invalid command\n")
}

func printCmdError(app string, err string) {
	if err != "" {
		fmt.Printf("%v: %v\n", app, err)
	}
}