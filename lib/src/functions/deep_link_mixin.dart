import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';


mixin DeepLinkMixin<T extends StatefulWidget> on State<T> {
 
  StreamSubscription? _sub;

  @override
  void initState() {
    _sub = uriLinkStream.listen(_onNewNotify);
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void onDeepLinkNotify(Uri? uri);

  void _onNewNotify(Uri? uri) {
    if (mounted) onDeepLinkNotify(uri);
  }
}
