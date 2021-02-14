part of model_notifier;

final apiDocumentProvider =
    ModelProvider.family.autoDispose<ApiDynamicDocumentModel, String>(
  (_, endpoint) => ApiDynamicDocumentModel(endpoint)..load(),
);

class ApiDynamicDocumentModel extends ApiDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic> {
  ApiDynamicDocumentModel(String endpoint,
      [Map<String, dynamic>? map])
      : super(endpoint, map ?? {});

  @override
  @protected
  Map<String, dynamic> get initialValue => {};

  @override
  Map<String, dynamic> fromMap(Map<String, Object> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, Object> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();
}
