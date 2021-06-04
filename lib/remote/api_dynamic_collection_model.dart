part of model_notifier;

final apiCollectionProvider =
    ModelProvider.family<ApiDynamicCollectionModel, String>(
  (_, endpoint) => ApiDynamicCollectionModel(endpoint),
);

class ApiDynamicCollectionModel extends ApiCollectionModel<DynamicMap> {
  ApiDynamicCollectionModel(String endpoint, [List<MapModel<dynamic>>? value])
      : super(endpoint, value ?? []);

  @override
  List<DynamicMap> fromCollection(List<Object> list) => list.cast<DynamicMap>();

  @override
  List<Object> toCollection(List<DynamicMap> list) => list.cast<Object>();

  @override
  DynamicMap createDocument() => {};
}
