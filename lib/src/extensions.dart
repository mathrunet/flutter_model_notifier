part of model_notifier;

extension ChangeNotifierMapExtensions<T extends ChangeNotifier> on Iterable<T> {
  /// Convert the list of [ChangeNotifier] to the list of widgets.
  ///
  /// It not only converts,
  /// but also listens for changes in each item and rebuilds only that part of the item if there are changes in each item.
  ///
  /// Easily create high performance lists.
  ///
  /// [callback] with the content of the widget.
  List<Widget> mapWidget(Widget? Function(T item) callback) {
    return map((item) {
      return ChangeNotifierListener<T>(
        notifier: item,
        builder: (context, notifier) =>
            callback.call(notifier) ?? const SizedBox(),
      );
    }).toList();
  }
}

extension NullableAsyncValueExtensions<T> on AsyncValue<T>? {
  /// Get the value.
  ///
  /// If it is itself null or the value is null, [defaultValue] is returned.
  T value(T defaultValue) {
    if (this == null) {
      return defaultValue;
    }
    return this!.data?.value ?? defaultValue;
  }
}

extension AsyncValueExtensions<T> on AsyncValue<T> {
  /// Get the value.
  ///
  /// If it is itself null or the value is null, [defaultValue] is returned.
  T value(T defaultValue) {
    return data?.value ?? defaultValue;
  }
}
