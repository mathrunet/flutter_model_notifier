part of model_notifier;

abstract class StoredModel<T, Result extends Model<T>> extends Model<T> {
  Future<Result> load();
  Future<Result> save();
}
