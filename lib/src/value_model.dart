part of model_notifier;

abstract class ValueModel<T> extends Model<T> {
  ValueModel(T value)
      : _value = value,
        super();

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    if (notifyOnChangeValue) {
      streamController.sink.add(value);
      notifyListeners();
    }
  }

  bool get notifyOnChangeValue => true;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => value?.hashCode ?? super.hashCode;

  @override
  String toString() => "${describeIdentity(this)}($value)";
}
