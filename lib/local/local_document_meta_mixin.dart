part of model_notifier;

mixin LocalDocumentMetaMixin<T> on LocalDocumentModel<T> {
  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    save[timeValueKey] = DateTime.now().millisecondsSinceEpoch;
    save[uidValueKey] = path.split("/").last;
    final language = Localize.language;
    if (language.isNotEmpty) {
      save[localeValueKey] = language;
    }
    return super.filterOnSave(save);
  }
}
