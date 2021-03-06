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
        listenable: item,
        builder: (context, listenable) =>
            callback.call(listenable) ?? const SizedBox(),
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
      final res = <K, V>{};
      for (final tmp in value.entries) {
        res[tmp.key] = tmp.value;
      }
      for (final tmp in others.value.entries) {
        final key = convertKeys?.call(tmp.key) ?? tmp.key;
        final value = convertValues?.call(tmp.value) ?? tmp.value;
        res[key] = value;
      }
      return res;
    };
    return ListenableMap<K, V>.from(filter(const {}))
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

extension MasamuneDynamicMapExtensions on DynamicMap {
  /// Get the uid.
  ///
  /// Same process as below.
  /// ```
  /// this.get(Const.uid, "");
  /// ```
  String get uid {
    return this.get(Const.uid, "");
  }

  /// Get the time.
  ///
  /// Same process as below.
  /// ```
  /// this.get(Const.time, DateTime.now().millisecondsSinceEpoch);
  /// ```
  int get time {
    return this.get(Const.time, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the locale.
  ///
  /// Same process as below.
  /// ```
  /// this.get(MetaConst.locale, Localize.locale);
  /// ```
  String get locale {
    return this.get(MetaConst.locale, Localize.locale);
  }
}
