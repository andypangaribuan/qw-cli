/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import (
	"fmt"
	"qw/util"
	"strings"
	"sync"
)

func podEvents(args []string) {
	if len(args) == 0 {
		util.PrintInvalidCommand()
		return
	}

	var (
		optNs  = ""
		optDep = ""
		optPod = ""
	)

	_, _, opts, _, _ := vo(args)
	if len(opts) == 0 {
		util.PrintInvalidCommand()
		return
	}

	for _, o := range opts {
		switch o[0] {
		case "-n":
			optNs = o[1]
		case "-d":
			optDep = o[1]
		case "-p":
			optPod = o[1]
		}
	}

	if optDep == "" && optPod == "" {
		util.PrintInvalidCommand()
		return
	}

	if optPod != "" && optDep == "" {
		util.PrintInvalidCommand()
		return
	}

	opts = make([][]string, 0)
	if optNs != "" {
		opts = append(opts, []string{"-n", optNs})
	}

	podOut, podErr := cmd(shof([]string{}, opts, "kubectl get pod -l app=%v", optDep))
	if podErr != "" {
		printCmdError(optDep, podErr)
		return
	}

	_, podVals := util.MapKV(podOut, "NAME", "READY", "STATUS", "RESTARTS", "AGE")

	var (
		pods   = make([]string, 0)
		sm     sync.Map
		wg     sync.WaitGroup
		output string
	)

	for _, pod := range podVals {
		name := pod[0]

		if optPod == "" {
			pods = append(pods, name)
		} else if optPod == name {
			pods = append(pods, name)
		}
	}

	if len(pods) == 0 {
		fmt.Printf("have no pod\n")
		return
	}

	for _, pod := range pods {
		wg.Add(1)

		go func() {
			out, err := cmd(shof([]string{}, opts, "kubectl describe pod %v", pod))
			if err == "" {
				var (
					lines       = strings.Split(out, "\n")
					foundEvents = false
					eventKey    = "Events:"
					eventValue  = ""
				)

				for _, line := range lines {
					if foundEvents {
						if len(line) > 2 && line[:2] == "  " {
							eventValue += "\n" + line
							continue
						} else {
							break
						}
					}

					if strings.Contains(line, eventKey) {
						foundEvents = true
						eventValue = line
					}
				}

				if eventValue != "" {
					sm.Store(pod, eventValue)
				}
			}

			wg.Done()
		}()
	}

	wg.Wait()

	for _, pod := range pods {
		val, ok := sm.Load(pod)
		if ok {
			if output != "" {
				output += "\n\n"
			}

			output += fmt.Sprintf("Pod: %v\n", pod)
			output += val.(string)
		}
	}

	fmt.Println(output)
}
