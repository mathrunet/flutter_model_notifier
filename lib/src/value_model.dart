part of model_notifier;

abstract class ValueModel<T> extends ValueNotifier<T>
    implements Model<T>, StoredModel<T> {
  ValueModel(T value) : super(value) {
    initState();
  }

  @protected
  @mustCallSuper
  void initState() {}

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => value?.hashCode ?? super.hashCode;

  @override
  String toString() => "${describeIdentity(this)}($value)";
}
