import 'package:flutter/material.dart';

import '../data/echo_repository.dart';

class EchoScope extends InheritedNotifier<EchoRepository> {
  const EchoScope({
    super.key,
    required EchoRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static EchoRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EchoScope>();
    assert(scope != null, 'EchoScope not found');
    return scope!.notifier!;
  }
}
