part of model_notifier;

abstract class DynamicDocumentModel<T> extends MapModel<T> {
  DynamicDocumentModel([Map<String, T> map = const {}]) : super(map);
}
