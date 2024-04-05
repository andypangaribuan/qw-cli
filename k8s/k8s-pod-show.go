/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import (
	"fmt"
	"qw/util"
	"strconv"
	"strings"
	"sync"
)

func podShow(args []string) {
	if len(args) == 0 {
		invalid()
		return
	}

	val, opt, opts, _, exts := vo(args)
	if len(val) == 0 {
		invalid()
		return
	}

	var (
		sm     sync.Map
		wg     sync.WaitGroup
		output string
	)

	for i, app := range val {
		wg.Add(1)
		go func() {
			line := execPodShow(app, opt, opts)

			if i != len(val)-1 {
				dvalNL := 5
				if v, ok := util.FindExtVal(exts, "+nl"); ok {
					if n, err := strconv.Atoi(v); err == nil {
						dvalNL = n
					}
				}

				line += "\n"
				for i := 0; i < dvalNL; i++ {
					line += "\n"
				}
			}

			sm.Store(i, line)
			wg.Done()
		}()
	}

	wg.Wait()

	for i := range val {
		val, ok := sm.Load(i)
		if ok {
			output += val.(string)
		}
	}

	fmt.Println(output)
}

func execPodShow(app string, opt []string, opts [][]string) string {
	var (
		wg             sync.WaitGroup
		hpaOut, hpaErr string
		podOut, podErr string
		topOut, topErr string
		imgOut, imgErr string
	)

	wg.Add(1)
	go func() {
		hpaOut, hpaErr = cmd(shof(opt, opts, "kubectl get hpa %v", app))
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		podOut, podErr = cmd(shof(opt, opts, "kubectl get pod -l app=%v", app))
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		topOut, topErr = cmd(shof(opt, opts, "kubectl top pod -l app=%v", app))
		wg.Done()
	}()

	wg.Add(1)
	go func() {
		imgOut, imgErr = cmd(shof(opt, opts, "kubectl get pods -o custom-columns='NAME:.metadata.name,IMAGES:.spec.containers[*].image' -l app=%v", app))
		wg.Done()
	}()

	wg.Wait()

	if hpaErr != "" {
		printCmdError(app, hpaErr)
		return ""
	}

	if podErr != "" {
		printCmdError(app, podErr)
		return ""
	}

	if topErr != "" {
		printCmdError(app, topErr)
		return ""
	}

	if imgErr != "" {
		printCmdError(app, imgErr)
		return ""
	}

	hpaHeader, hpaVals := util.MapKV(hpaOut, "NAME", "REFERENCE", "TARGETS", "MINPODS", "MAXPODS", "REPLICAS", "AGE")
	podHeader, podVals := util.MapKV(podOut, "NAME", "READY", "STATUS", "RESTARTS", "AGE")
	topHeader, topVals := util.MapKV(topOut, "NAME", "CPU(cores)", "MEMORY(bytes)")
	imgHeader, imgVals := util.MapKV(imgOut, "NAME", "IMAGES")

	var (
		hpaItems     = make([][]string, 0)
		podItems     = make([][]string, 0)
		numberLength = len(strconv.Itoa(len(podVals)))

		idxHpaName     = hpaHeader["NAME"]
		idxHpaTargets  = hpaHeader["TARGETS"]
		idxHpaMinPods  = hpaHeader["MINPODS"]
		idxHpaMaxPods  = hpaHeader["MAXPODS"]
		idxHpaReplicas = hpaHeader["REPLICAS"]
		idxHpaAge      = hpaHeader["AGE"]

		idxPodName     = podHeader["NAME"]
		idxPodReady    = podHeader["READY"]
		idxPodStatus   = podHeader["STATUS"]
		idxPodRestarts = podHeader["RESTARTS"]
		idxPodAge      = podHeader["AGE"]

		idxTopCpu = topHeader["CPU(cores)"]
		idxTopMem = topHeader["MEMORY(bytes)"]

		idxImgImages = imgHeader["IMAGES"]
	)

	hpaItems = append(hpaItems, []string{"", "NAME", "TARGETS", "MIN", "MAX", "REP", "AGE"})
	podItems = append(podItems, []string{"", "NAME", "READY", "STATUS", "CPU", "MEM", "RES", "AGE", "IMGV"})

	for _, v := range hpaVals {
		hpaItems = append(hpaItems, []string{
			util.AddSpace("", numberLength, true),
			v[idxHpaName],
			v[idxHpaTargets],
			v[idxHpaMinPods],
			v[idxHpaMaxPods],
			v[idxHpaReplicas],
			v[idxHpaAge],
		})
	}

	for i, pod := range podVals {
		var (
			top        = getVal(topHeader, topVals, "NAME", pod[idxPodName])
			img        = getVal(imgHeader, imgVals, "NAME", pod[idxPodName])
			cpu        = "-"
			mem        = "-"
			imgVersion = ""
		)

		if len(top) > 0 {
			cpu = top[idxTopMem]
			mem = top[idxTopCpu]
		}

		if len(img) > 0 {
			imgVersion = img[idxImgImages]
			ls := strings.Split(imgVersion, ",")
			if len(ls) > 1 {
				for _, v := range ls {
					if !strings.Contains(v, "/linkerd/") {
						imgVersion = v
						break
					}
				}
			}

			ls = strings.Split(imgVersion, "/")
			imgVersion = ls[len(ls)-1]

			ls = strings.Split(imgVersion, ":")
			imgVersion = ls[len(ls)-1]
		}

		podItems = append(podItems, []string{
			util.AddSpace(strconv.Itoa(i+1), numberLength, true),
			strings.ReplaceAll(pod[idxPodName], app+"-", ""),
			pod[idxPodReady],
			pod[idxPodStatus],
			cpu,
			mem,
			pod[idxPodRestarts],
			pod[idxPodAge],
			imgVersion,
		})
	}

	return util.BuildLines(hpaItems) + "\n\n" + util.BuildLines(podItems)
}

func getVal(podHeader map[string]int, vals [][]string, header string, key string) []string {
	hi, ok := podHeader[header]
	if !ok {
		return nil
	}

	for _, val := range vals {
		if val[hi] == key {
			return val
		}
	}

	return nil
}
