part of model_notifier;

abstract class DocumentModel<T> extends ValueModel<T> {
  DocumentModel(T value) : super(value);

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T value);
}
