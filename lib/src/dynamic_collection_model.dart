part of model_notifier;

/// Collection model for flexibly modifying the contents of an object that is primarily a [Map<String, dynamic>].
abstract class DynamicCollectionModel<T extends DynamicDocumentModel>
    implements ListModel<T> {}
