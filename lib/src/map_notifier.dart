part of model_notifier;

abstract class MapNotifier<T> extends ChangeNotifier implements Map<String, T> {
  MapNotifier([Map<String, T> map = const {}]) : _map = map;

  final Map<String, T> _map;

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _map.clear();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (_map == other) {
      return true;
    }
    if (other is MapNotifier) {
      if (_map.length != other.length) {
        return false;
      }
      for (final key in _map.keys) {
        if (!other.containsKey(key) || _map[key] != other[key]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _map.hashCode;

  @override
  T? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, T value) {
    if (_map.containsKey(key) && _map[key] == value) {
      return;
    }
    _map[key] = value;
    notifyListeners();
  }

  @override
  void addAll(Map<String, T> other) {
    _map.addAll(other);
    notifyListeners();
  }

  @override
  void addEntries(Iterable<MapEntry<String, T>> newEntries) {
    _map.addEntries(newEntries);
    notifyListeners();
  }

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  @override
  void clear() {
    _map.clear();
    notifyListeners();
  }

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _map.containsValue(value);

  @override
  Iterable<MapEntry<String, T>> get entries => _map.entries;

  @override
  void forEach(void Function(String key, T value) action) {
    _map.forEach(action);
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<String> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(String key, T value) convert) {
    return _map.map<K2, V2>(convert);
  }

  @override
  T putIfAbsent(String key, T Function() ifAbsent) {
    final value = _map.putIfAbsent(key, ifAbsent);
    notifyListeners();
    return value;
  }

  @override
  T? remove(Object? key) {
    final value = _map.remove(key);
    if (value != null) {
      notifyListeners();
    }
    return value;
  }

  @override
  void removeWhere(bool Function(String key, T value) test) {
    _map.removeWhere((key, value) {
      if (!test(key, value)) {
        return false;
      }
      notifyListeners();
      return true;
    });
  }

  @override
  T update(String key, T Function(T value) update, {T Function()? ifAbsent}) {
    final value = _map.update(key, update, ifAbsent: ifAbsent);
    notifyListeners();
    return value;
  }

  @override
  void updateAll(T Function(String key, T value) update) {
    _map.updateAll(update);
    notifyListeners();
  }

  @override
  Iterable<T> get values => _map.values;
}
