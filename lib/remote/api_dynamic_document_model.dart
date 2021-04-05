part of model_notifier;

final apiDocumentProvider =
    ModelProvider.family<ApiDynamicDocumentModel, String>(
  (_, endpoint) => ApiDynamicDocumentModel(endpoint),
);

class ApiDynamicDocumentModel extends ApiDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic> {
  ApiDynamicDocumentModel(String endpoint, [Map<String, dynamic>? map])
      : super(endpoint, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();
}
