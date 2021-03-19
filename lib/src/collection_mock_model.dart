part of model_notifier;

/// Abstract class for creating mocks for collections.
///
/// It is necessary to add the mock method.
abstract class CollectionMockModel<T, Result> extends ValueModel<List<T>> {
  /// Abstract class for creating mocks for collections.
  ///
  /// It is necessary to add the mock method.
  CollectionMockModel([List<T>? value]) : super(value ?? []);

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  Result mock(List<T> mockDataList);

  /// Initial value of mock.
  @protected
  List<T> get initialMock;
}
