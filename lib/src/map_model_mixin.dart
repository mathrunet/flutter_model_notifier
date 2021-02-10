part of model_notifier;

mixin MapModelMixin<T> on ValueModel<Map<String, T>> implements Map<String, T> {
  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    super.value.clear();
  }

  @override
  bool get notifyOnChangeValue => true;

  bool get notifyOnChangeMap => true;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (super.value == other) {
      return true;
    }
    if (other is MapNotifier) {
      if (super.value.length != other.length) {
        return false;
      }
      for (final key in super.value.keys) {
        if (!other.containsKey(key) || super.value[key] != other[key]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.value.hashCode;

  @override
  T? operator [](Object? key) => super.value[key];

  @override
  void operator []=(String key, T value) {
    if (super.value.containsKey(key) && super.value[key] == value) {
      return;
    }
    super.value[key] = value;
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
  }

  @override
  void addAll(Map<String, T> other) {
    super.value.addAll(other);
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
  }

  @override
  void addEntries(Iterable<MapEntry<String, T>> newEntries) {
    super.value.addEntries(newEntries);
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
  }

  @override
  Map<RK, RV> cast<RK, RV>() => value.cast<RK, RV>();

  @override
  void clear() {
    super.value.clear();
    if (notifyOnChangeMap) {
      notifyListeners();
    }
  }

  @override
  bool containsKey(Object? key) => super.value.containsKey(key);

  @override
  bool containsValue(Object? value) => super.value.containsValue(value);

  @override
  Iterable<MapEntry<String, T>> get entries => super.value.entries;

  @override
  void forEach(void Function(String key, T value) action) {
    super.value.forEach(action);
  }

  @override
  bool get isEmpty => super.value.isEmpty;

  @override
  bool get isNotEmpty => super.value.isNotEmpty;

  @override
  Iterable<String> get keys => super.value.keys;

  @override
  int get length => super.value.length;

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(String key, T value) convert) {
    return super.value.map<K2, V2>(convert);
  }

  @override
  T putIfAbsent(String key, T Function() ifAbsent) {
    final value = super.value.putIfAbsent(key, ifAbsent);
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
    return value;
  }

  @override
  T? remove(Object? key) {
    final value = super.value.remove(key);
    if (value != null) {
      if (notifyOnChangeMap) {
        streamController.sink.add(super.value);
        notifyListeners();
      }
    }
    return value;
  }

  @override
  void removeWhere(bool Function(String key, T value) test) {
    super.value.removeWhere((key, value) {
      if (!test(key, value)) {
        return false;
      }
      if (notifyOnChangeMap) {
        streamController.sink.add(super.value);
        notifyListeners();
      }
      return true;
    });
  }

  @override
  T update(String key, T Function(T value) update, {T Function()? ifAbsent}) {
    final value = super.value.update(key, update, ifAbsent: ifAbsent);
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
    return value;
  }

  @override
  void updateAll(T Function(String key, T value) update) {
    super.value.updateAll(update);
    if (notifyOnChangeMap) {
      streamController.sink.add(super.value);
      notifyListeners();
    }
  }

  @override
  Iterable<T> get values => super.value.values;
}
