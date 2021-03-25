part of model_notifier;

/// Abstract class that defines methods for reading and writing data.
abstract class StoredModel<T, Result extends Model<T>> extends Model<T> {
  /// Retrieves data and updates the data in the model.
  /// 
  /// You will be notified of model updates at the time they are retrieved.
  /// 
  /// In addition,
  /// the updated [Resuult] can be obtained at the stage where the loading is finished.
  Future<Result> load();
  /// Data stored in the model is stored in a database external to the app that is tied to the model.
  /// 
  /// The updated [Resuult] can be obtained at the stage where the loading is finished.
  Future<Result> save();
}
