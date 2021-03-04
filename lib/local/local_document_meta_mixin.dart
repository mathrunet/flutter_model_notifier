part of model_notifier;

mixin LocalDocumentMetaMixin<T> on LocalDocumentModel<T> {
  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    save[timeValueKey] = DateTime.now().millisecondsSinceEpoch;
    save[uidValueKey] = path.split("/").last;
    return super.filterOnSave(save);
  }
}
