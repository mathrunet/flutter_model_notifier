part of model_notifier;

final apiDocumentProvider =
    ModelProvider.family<ApiDynamicDocumentModel, String>(
  (_, endpoint) => ApiDynamicDocumentModel(endpoint),
);

class ApiDynamicDocumentModel extends ApiDocumentModel<DynamicMap>
    with MapModelMixin<dynamic> {
  ApiDynamicDocumentModel(String endpoint, [DynamicMap? map])
      : super(endpoint, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  DynamicMap fromMap(DynamicMap map) => map.cast<String, dynamic>();

  @override
  DynamicMap toMap(DynamicMap value) => value.cast<String, Object>();
}
