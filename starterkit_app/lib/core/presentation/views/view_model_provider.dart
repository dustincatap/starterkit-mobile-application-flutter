// coverage:ignore-file

import 'package:flutter/widgets.dart';

class ViewModelProvider<T> extends InheritedWidget {
  const ViewModelProvider({required this.viewModel, required super.child, super.key});

  final T viewModel;

  static ViewModelProvider<T> of<T>(BuildContext context) {
    final InheritedElement? viewModelProvider = context.getElementForInheritedWidgetOfExactType<ViewModelProvider<T>>();

    if (viewModelProvider == null || viewModelProvider.widget is! ViewModelProvider<T>) {
      throw StateError('ViewModelProvider is not found');
    }

    return viewModelProvider.widget as ViewModelProvider<T>;
  }

  @override
  bool updateShouldNotify(ViewModelProvider<T> oldWidget) {
    return true;
  }
}

extension ViewModelProviderExtension on BuildContext {
  T viewModel<T>() {
    return ViewModelProvider.of<T>(this).viewModel;
  }
}
