part of model_notifier;

/// Base class for holding and manipulating data from a runtime database as a document of [T].
///
/// The runtime database is a Json database.
/// Specify a path to specify the location of the contents.
///
/// In addition, since it can be used as [Map],
/// it is possible to operate the content as it is.
abstract class RuntimeDocumentModel<T> extends DocumentModel<T>
    implements DocumentMockModel<T, RuntimeDocumentModel<T>> {
  /// Base class for holding and manipulating data from a runtime database as a document of [T].
  ///
  /// The runtime database is a Json database.
  /// Specify a path to specify the location of the contents.
  ///
  /// In addition, since it can be used as [Map],
  /// it is possible to operate the content as it is.
  RuntimeDocumentModel(this.path, T initialValue)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(initialValue);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old value as evaluated by the equality operator ==,
  /// this class notifies its listeners.
  @override
  set value(T newValue) {
    if (super.value == newValue) {
      return;
    }
    super.value = newValue;
    // _LocalDatabase._notifyChildChanges(this);
  }

  /// Key for UID values.
  final String uidValueKey = "uid";

  /// Key for time values.
  final String timeValueKey = "time";

  /// Key for locale values.
  final String localeValueKey = "@locale";

  /// The method to be executed when initialization is performed.
  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isEnabledMockup && initialMock != null) {
      // ignore: null_check_on_nullable_type_parameter
      value = initialMock!;
    }
  }

  /// Initial value of mock.
  @override
  @protected
  final T? initialMock = null;

  /// Path of the local database.
  final String path;

  /// You can filter the loaded content when it is loaded.
  ///
  /// Edit the value of [loaded] and return.
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnLoad(Map<String, dynamic> loaded) => loaded;

  /// You can filter the saving content when it is saving.
  ///
  /// Edit the value of [save] and return.
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) => save;

  /// Register the data for the mock.
  ///
  /// Once the data for the mock is registered, it will not be changed.
  @override
  RuntimeDocumentModel<T> mock(T mockData) {
    if (!Config.isEnabledMockup) {
      return this;
    }
    if (value == mockData) {
      return this;
    }
    value = mockData;
    notifyListeners();
    return this;
  }

  /// The equality operator.
  ///
  /// The default behavior for all [Object]s is to return true if and only if this object and [other] are the same object.
  ///
  /// Override this method to specify a different equality relation on a class. The overriding method must still be an equivalence relation. That is, it must be:
  ///
  /// Total: It must return a boolean for all arguments. It should never throw.
  ///
  /// Reflexive: For all objects o, o == o must be true.
  ///
  /// Symmetric: For all objects o1 and o2, o1 == o2 and o2 == o1 must either both be true, or both be false.
  ///
  /// Transitive: For all objects o1, o2, and o3, if o1 == o2 and o2 == o3 are true, then o1 == o3 must be true.
  ///
  /// The method should also be consistent over time, so whether two objects are equal should only change if at least one of the objects was modified.
  ///
  /// If a subclass overrides the equality operator, it should override the [hashCode] method as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// The hash code for this object.
  ///
  /// A hash code is a single integer which represents the state of the object that affects [operator ==] comparisons.
  ///
  /// All objects have hash codes. The default hash code implemented by [Object] represents only the identity of the object,
  /// the same way as the default [operator ==] implementation only considers objects equal if they are identical (see [identityHashCode]).
  ///
  /// If [operator ==] is overridden to use the object state instead,
  /// the hash code must also be changed to represent that state,
  /// otherwise the object cannot be used in hash based data structures like the default [Set] and [Map] implementations.
  ///
  /// Hash codes must be the same for objects that are equal to each other according to [operator ==].
  /// The hash code of an object should only change if the object changes in a way that affects equality.
  /// There are no further requirements for the hash codes. They need not be consistent between executions of the same program and there are no distribution guarantees.
  ///
  /// Objects that are not equal are allowed to have the same hash code.
  /// It is even technically allowed that all instances have the same hash code,
  /// but if clashes happen too often, it may reduce the efficiency of hash-based data structures like [HashSet] or [HashMap].
  ///
  /// If a subclass overrides [hashCode],
  /// it should override the [operator ==] operator as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ path.hashCode;
}
