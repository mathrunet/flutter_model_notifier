part of model_notifier;

/// Abstract class for creating mocks for documents.
///
/// It is necessary to add the mock method.
abstract class DocumentMockModel<T, Result> extends ValueModel<T> {
  /// Abstract class for creating mocks for documents.
  ///
  /// It is necessary to add the mock method.
  DocumentMockModel(T value) : super(value);

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  Result mock(T mockData);

  /// Initial value of mock.
  @protected
  T? get initialMock;
}
