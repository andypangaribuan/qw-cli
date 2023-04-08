/*
 * Copyright (c) 2023.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dtg/dtg.dart';
import 'package:fdation/fdation.dart';
import 'package:qw_cli/model/meta/k8s-pods-meta.dart';

import 'func.dart';

class K8s {
  void help(Args ar) {
    if (ar.arg1.isNotEmpty) {
      printCommandNotFound();
    }

    dg.print.table([
      ['k8s', '→', 'show-pods']
    ]);
  }

  void showPods(Args ar) async {
    if (!ar.haveOpt('-ns') && !ar.haveOpt('-namespace')) {
      print('opts:');
      dg.print.table([
        ['-ns', '→', 'namespace (alt: -namespace)'],
        ['-exclude', '→', 'namespace (optional)'],
        ['-only', '→', 'specific pod name (optional)'],
        ['-order-by', '→', 'override order by (optional)'],
        ['--no-pod', '→', 'remove pod from result (optional)'],
        ['--no-name', '→', 'remove name from result (optional)'],
        ['--show-created-at', '→', 'show pod creation timestamp (optional)'],
      ]);
      return;
    }

    final namespace = requiredOpt(ar, opt: '-ns', altOpt: '-namespace', msg: 'Enter namespace:');

    final excludeContainers = <String>[];
    final exclude = ar.opt('-exclude');
    if (exclude != null) {
      final ls = exclude.split(',');
      excludeContainers.addAll(ls);
    }

    final withNoName = ar.haveOpt('--no-name');
    final withNoPod = ar.haveOpt('--no-pod');
    final withCreatedAt = ar.haveOpt('--show-created-at');

    final onlyPods = <String>[];
    final onlyPodValue = ar.opt('-only');
    if (onlyPodValue != null) {
      final ls = onlyPodValue.split(',');
      if (ls.isNotEmpty) {
        onlyPods.addAll(ls);
      }
    }

    final ordersBy = <List<String>>[];
    var orderByValue = ar.opt('-order-by');
    if (orderByValue != null) {
      orderByValue = orderByValue.replaceAll('-', '_').toUpperCase();
      final ls = orderByValue.split(',');
      for (final e in ls) {
        final arr = e.split(':');
        if (arr.isNotEmpty) {
          var ad = arr.length > 1 ? arr[1] : 'ASC';
          if (ad != 'ASC' && ad != 'DESC') {
            ad = 'ASC';
          }

          ordersBy.add([arr[0], ad]);
        }
      }
    }

    if (ordersBy.isEmpty) {
      ordersBy.add(['READY', 'ASC']);
      ordersBy.add(['POD', 'ASC']);
      ordersBy.add(['CPU', 'DESC']);
    }

    var command = 'kubectl get pods -n $namespace -o json';
    final resPodJson = await dg.sh.exec(command: command);
    if (resPodJson.stderr.isNotEmpty) {
      print(resPodJson.stderr);
      return;
    }

    command = 'kubectl get pods -n $namespace';
    final resPodTable = await dg.sh.exec(command: command);
    if (resPodTable.stderr.isNotEmpty) {
      print(resPodTable.stderr);
      return;
    }

    command = 'kubectl top pod -n $namespace';
    final resTopPodTable = await dg.sh.exec(command: command);
    if (resTopPodTable.stderr.isNotEmpty) {
      print(resTopPodTable.stderr);
      return;
    }

    final pods = K8sPodsMeta.fromJsonLs(fd.json.deserialize(resPodJson.stdout));

    var header = ['NAME', 'READY', 'STATUS', 'RESTARTS', 'AGE'];
    final podTable = dg.sh.toTable(output: resPodTable.stdout, lsHeader: header, display: header);

    header = ['NAME', 'CPU(cores)', 'MEMORY(bytes)'];
    final topTable = dg.sh.toTable(output: resTopPodTable.stdout, lsHeader: header, display: header);

    header = ['POD', 'NAME', 'READY', 'STATUS', 'CPU', 'MEM', 'RESTARTS', 'AGE', 'IMAGE', 'CREATED_AT'];
    final idxPod = header.indexOf('POD');
    final idxName = header.indexOf('NAME');
    final idxCreatedAt = header.indexOf('CREATED_AT');

    final table = <List<String>>[];
    for (final pod in pods) {
      final podName = pod.containerName;
      final name = pod.name;
      final image = pod.simpleImage;
      final createdAt = pod.createdAt;
      var ready = '<unknown>';
      var status = '<unknown>';
      var restarts = '<unknown>';
      var age = '<unknown>';
      var cpu = '<unknown>';
      var memory = '<unknown>';

      if (excludeContainers.isNotEmpty) {
        if (excludeContainers.safeFirstWhere((e) => e == podName) != null) {
          continue;
        }
      }

      if (onlyPods.isNotEmpty) {
        if (!onlyPods.contains(podName)) {
          continue;
        }
      }

      var ls = podTable.safeFirstWhere((e) => e[0] == name);
      if (ls != null) {
        ready = ls[1];
        status = ls[2];
        restarts = ls[3];
        age = ls[4];
      }

      ls = topTable.safeFirstWhere((e) => e[0] == name);
      if (ls != null) {
        cpu = ls[1];
        memory = ls[2];
      }

      final details = [podName, name, ready, status, cpu, memory, restarts, age, image, createdAt];
      table.add(details);
    }

    final comparators = <Comparator<List<String>>>[];

    for (final o in ordersBy) {
      final idx = header.indexOf(o[0]);
      if (idx > -1) {
        comparators.add((a, b) => o[1] == 'DESC' ? b[idx].compareTo(a[idx]) : a[idx].compareTo(b[idx]));
      }
    }

    if (comparators.isNotEmpty) {
      table.sort(
        (a, b) {
          return comparators.map((e) => e(a, b)).firstWhere(
                (e) => e != 0,
                orElse: () => 0,
              );
        },
      );
    }

    // table.sort((a, b) => <Comparator<List<String>>>[
    //       (a, b) => a[1].compareTo(b[1]),
    //       (a, b) => a[0].compareTo(b[0]),
    //       (a, b) => b[3].compareTo(a[3]),
    //     ].map((e) => e(a, b)).firstWhere(
    //           (e) => e != 0,
    //           orElse: () => 0,
    //         ));

    table.insert(0, header);

    for (var e in table) {
      if (!withCreatedAt) {
        e.removeAt(idxCreatedAt);
      }

      if (withNoName) {
        e.removeAt(idxName);
      }

      if (withNoPod) {
        e.removeAt(idxPod);
      }
    }

    dg.print.table(table);
  }
}
