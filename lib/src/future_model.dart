part of model_notifier;

/// Abstract class for creating a model that can wait on Future.
abstract class FutureModel<T> extends Model<T> {
  /// Returns itself after the load/save finishes.
  Future<void>? get future;
}
