part of model_notifier;

class ChangeNoitierListener<T extends ChangeNotifier> extends StatefulWidget {
  const ChangeNoitierListener({
    Key? key,
    required this.notifier,
    required this.builder,
  }) : super(key: key);

  final T notifier;
  final Widget Function(BuildContext context, T notifier) builder;
  @override
  State<StatefulWidget> createState() => _ChangeNoitierListenerState<T>();
}

class _ChangeNoitierListenerState<T extends ChangeNotifier>
    extends State<ChangeNoitierListener<T>> {
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
  void didUpdateWidget(ChangeNoitierListener<T> oldWidget) {
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
