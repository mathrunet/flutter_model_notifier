part of model_notifier;

extension ChangeNotifierMapExtensions<T extends ChangeNotifier> on Iterable<T> {
  /// After replacing the data in the list, delete the null.
  ///
  /// [callback]: Callback function used in map.
  List<Widget> mapWidget(Widget? Function(T item) callback) {
    return map((item) {
      return ChangeNoitierListener<T>(
        notifier: item,
        builder: (context, notifier) =>
            callback.call(notifier) ?? const SizedBox(),
      );
    }).toList();
  }
}
