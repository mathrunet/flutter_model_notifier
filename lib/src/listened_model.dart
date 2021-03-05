part of model_notifier;

abstract class ListenedModel<T, Result extends Model<T>> extends Model<T> {
  Future<Result> listen();
}
