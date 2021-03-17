part of model_notifier;

/// Widget that listens for ChangeNotifiers and
/// rebuilds the widgets inside when there is an update.
class ChangeNotifierListener<T extends ChangeNotifier> extends StatefulWidget {
  /// Widget that listens for ChangeNotifiers and
  /// rebuilds the widgets inside when there is an update.
  const ChangeNotifierListener({
    Key? key,
    required this.notifier,
    required this.builder,
  }) : super(key: key);

  /// ChangeNotifier to monitor.
  final T notifier;

  /// Widget builder to update.
  final Widget Function(BuildContext context, T notifier) builder;

  /// Creates the mutable state for this widget at a given location in the tree.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] subclass:
  ///
  /// ```dart
  /// @override
  /// _MyState createState() => _MyState();
  /// ```
  ///
  /// The framework can call this method multiple times over the lifetime of
  /// a [StatefulWidget]. For example, if the widget is inserted into the tree
  /// in multiple locations, the framework will create a separate [State] object
  /// for each location. Similarly, if the widget is removed from the tree and
  /// later inserted into the tree again, the framework will call [createState]
  /// again to create a fresh [State] object, simplifying the lifecycle of
  /// [State] objects.
  @override
  @protected
  State<StatefulWidget> createState() => _ChangeNotifierListenerState<T>();
}

class _ChangeNotifierListenerState<T extends ChangeNotifier>
    extends State<ChangeNotifierListener<T>> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_handledOnUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    widget.notifier.removeListener(_handledOnUpdate);
  }

  @override
  void didUpdateWidget(ChangeNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifier != oldWidget.notifier) {
      oldWidget.notifier.removeListener(_handledOnUpdate);
      widget.notifier.addListener(_handledOnUpdate);
    }
  }

  void _handledOnUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.notifier);
  }
}
