part of model_notifier;

extension ListenableListExtensions<T extends Listenable> on Iterable<T> {
  /// Convert the list of [Listenable] to the list of widgets.
  ///
  /// It not only converts,
  /// but also listens for changes in each item and rebuilds only that part of the item if there are changes in each item.
  ///
  /// Easily create high performance lists.
  ///
  /// [callback] with the content of the widget.
  List<Widget> mapListenable(Widget? Function(T item) callback) {
    return map((item) {
      return ListenableListener<T>(
        notifier: item,
        builder: (context, notifier) =>
            callback.call(notifier) ?? const SizedBox(),
      );
    }).toList();
  }

  /// The data in the list of [others] is conditionally given to the current list.
  ///
  /// If [test] is `true`, [apply] will be executed.
  ///
  /// Otherwise, [orElse] will be executed.
  Iterable<K> setWhereListenable<K extends Listenable>(
    Iterable<T> others, {
    required bool Function(T original, T other) test,
    required K? Function(T original, T other) apply,
    K? Function(T original)? orElse,
  }) {
    final tmp = <K>[];
    for (final original in this) {
      final res = others.firstWhereOrNull((item) => test.call(original, item));
      if (res != null) {
        final applied = apply.call(original, res);
        if (applied != null) {
          tmp.add(applied);
        }
      } else {
        final applied = orElse?.call(original);
        if (applied != null) {
          tmp.add(applied);
        }
      }
    }
    return tmp;
  }
}

extension ListenableMapExtensions<K, V> on ValueListenable<Map<K, V>> {
  /// Merges the map in [others] with the current map.
  ///
  /// If the same key is found, the value of [others] has priority.
  ListenableMap<K, V> mergeListenable(
    ValueListenable<Map<K, V>> others, {
    K Function(K key)? convertKeys,
    V Function(V value)? convertValues,
  }) {
    final filter = (Map<K, V> origin) {
      if (origin.isNotEmpty) {
        origin.clear();
      }
      for (final tmp in value.entries) {
        origin[tmp.key] = tmp.value;
      }
      for (final tmp in others.value.entries) {
        final key = convertKeys?.call(tmp.key) ?? tmp.key;
        final value = convertValues?.call(tmp.value) ?? tmp.value;
        origin[key] = value;
      }
      return origin;
    };
    return ListenableMap<K, V>.from(filter(<K, V>{}))
      ..dependOn(this, filter)
      ..dependOn(others, filter);
  }
}

extension NullableAsyncValueExtensions<T> on AsyncValue<T>? {
  /// Get the value.
  ///
  /// If it is itself null or the value is null, [defaultValue] is returned.
  T value(T defaultValue) {
    if (this == null) {
      return defaultValue;
    }
    return this!.data?.value ?? defaultValue;
  }
}

extension AsyncValueExtensions<T> on AsyncValue<T> {
  /// Get the value.
  ///
  /// If it is itself null or the value is null, [defaultValue] is returned.
  T value(T defaultValue) {
    return data?.value ?? defaultValue;
  }
}
