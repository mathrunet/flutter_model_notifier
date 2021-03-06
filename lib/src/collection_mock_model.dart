part of model_notifier;

abstract class CollectionMockModel<T, Result> extends ValueModel<List<T>> {
  CollectionMockModel([List<T>? value]) : super(value ?? []);
  Result mock(List<Map<String, dynamic>> mockData);
}
