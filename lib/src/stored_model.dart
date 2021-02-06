part of model_notifier;

abstract class StoredModel<T> extends Model<T> {
  Future<T> load();
  Future<T> save();
}
