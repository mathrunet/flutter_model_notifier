part of model_notifier;

abstract class DocumentMockModel<T, Result> extends ValueModel<T> {
  DocumentMockModel(T value) : super(value);
  Result mock(Map<String, dynamic> mockData);
}
