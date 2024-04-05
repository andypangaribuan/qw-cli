/*
 * Copyright (c) 2024.
 * Created by Andy Pangaribuan <https://github.com/apangaribuan>.
 * All Rights Reserved.
 */

package k8s

import "qw/util"

func cmd(sh string, loadEnv ...bool) (string, string) {
	out, err := util.CMD(sh, loadEnv...)
	return util.StrClean(out), util.StrClean(err)
}

func vo(args []string) ([]string, []string, [][]string, []string, [][]string) {
	return util.GetVO(args)
}

func sho(sh string, opt []string, opts [][]string) string {
	return util.AddSHO(sh, opt, opts)
}

func shof(opt []string, opts [][]string, sh string, args ...any) string {
	return util.FullSHO(opt, opts, sh, args...)
}

func strClean(val string) string {
	return util.StrClean(val)
}

func getOptsVal(opts [][]string, key string) string {
	return util.GetOptsVal(opts, key)
}