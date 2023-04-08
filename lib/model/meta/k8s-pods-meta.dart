/*
 * Copyright (c) 2023.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

class K8sPodsMeta {
  String name;
  String containerName;
  String image;
  String simpleImage;
  String state;
  String stateInfo;
  int restartCount;
  String createdAt;

  K8sPodsMeta({
    required this.name,
    required this.containerName,
    required this.image,
    required this.simpleImage,
    required this.state,
    required this.stateInfo,
    required this.restartCount,
    required this.createdAt,
  });

  static List<K8sPodsMeta> fromJsonLs(Map<String, dynamic> json) {
    final ls = <K8sPodsMeta>[];

    for (final item in json['items']) {
      ls.add(K8sPodsMeta._fromJson(item));
    }

    return ls;
  }

  factory K8sPodsMeta._fromJson(Map<String, dynamic> item) {
    String image = _getImage(item);
    String simpleImage = image;
    final arr = image.split('/');
    if (arr.length > 2) {
      simpleImage = arr[arr.length - 1];
    }

    String state = 'unknown';
    String stateInfo = '';
    final status = _getContainerStatus(item);

    final jsonState = status['state'];
    if (jsonState != null) {
      Map<String, dynamic>? stateRunning = jsonState['running'];
      if (stateRunning != null) {
        state = 'running';
      }

      Map<String, dynamic>? stateWaiting = jsonState['waiting'];
      if (stateWaiting != null) {
        state = 'waiting';
        stateInfo = stateWaiting['reason'] ?? 'unknown';
      }
    }

    return K8sPodsMeta(
      name: item['metadata']?['name'] ?? '-',
      containerName: status['name'] ?? '',
      image: image,
      simpleImage: simpleImage,
      state: state,
      stateInfo: stateInfo,
      restartCount: status['restartCount'] ?? -1,
      createdAt: item['metadata']?['creationTimestamp'] ?? '-',
    );
  }

  static String _getImage(Map<String, dynamic> item) {
    final ls = item['spec']?['containers'];
    if (ls != null && ls is List && ls.isNotEmpty && ls[0] is Map<String, dynamic>) {
      return ls[0]['image'] ?? '';
    }

    return '';
  }

  static Map<String, dynamic> _getContainerStatus(Map<String, dynamic> item) {
    final ls = item['status']?['containerStatuses'];
    if (ls != null && ls is List && ls.isNotEmpty && ls[0] is Map<String, dynamic>) {
      return ls[0];
    }

    return {};
  }
}
