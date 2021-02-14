part of model_notifier;

final apiCollectionProvider =
    ModelProvider.family<ApiDynamicCollectionModel, String>(
  (_, endpoint) => ApiDynamicCollectionModel(endpoint)..load(),
);

class ApiDynamicCollectionModel
    extends ApiCollectionModel<Map<String, dynamic>> {
  ApiDynamicCollectionModel(String endpoint, [List<MapModel<dynamic>>? value])
      : super(endpoint, value ?? []);

  @override
  List<Map<String, dynamic>> fromCollection(List<Object> list) =>
      list.cast<Map<String, dynamic>>();

  @override
  List<Object> toCollection(List<Map<String, dynamic>> list) =>
      list.cast<Object>();

  @override
  Map<String, dynamic> createDocument() => {};
}
