part of model_notifier;

mixin ListModelMixin<T> on ValueModel<List<T>> implements List<T> {
  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    super.value.clear();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (super.value == other) {
      return true;
    }
    if (other is ListNotifier) {
      if (super.value.length != other.length) {
        return false;
      }
      for (int i = 0; i < super.value.length; i++) {
        if (super.value[i] != other[i]) {
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
  String toString() => IterableBase.iterableToShortString(this, "(", ")");

  @override
  set length(int value) {
    super.value.length = value;
    notifyListeners();
  }

  @override
  List<T> operator +(List<T> other) => super.value + other;

  @override
  T operator [](int index) => super.value[index];

  @override
  void operator []=(int index, T value) {
    super.value[index] = value;
    notifyListeners();
  }

  @override
  void add(T value) {
    super.value.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    super.value.addAll(iterable);
    notifyListeners();
  }

  @override
  void clear() {
    super.value.clear();
    notifyListeners();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    super.value.fillRange(start, end, fillValue);
    notifyListeners();
  }

  @override
  void insert(int index, T element) {
    super.value.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    super.value.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    if (super.value.remove(value)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  T removeAt(int index) {
    final value = super.value.removeAt(index);
    notifyListeners();
    return value;
  }

  @override
  T removeLast() {
    final value = super.value.removeLast();
    notifyListeners();
    return value;
  }

  @override
  void removeRange(int start, int end) {
    super.value.removeRange(start, end);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    super.value.removeWhere((e) {
      if (!test(e)) {
        return false;
      }
      return true;
    });
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacement) {
    super.value.replaceRange(start, end, replacement);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    super.value.retainWhere((e) {
      if (test(e)) {
        return true;
      }
      return false;
    });
    notifyListeners();
  }

  @override
  Iterable<T> get reversed {
    final iterable = super.value.reversed;
    notifyListeners();
    return iterable;
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    super.value.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    super.value.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    super.value.shuffle(random);
    notifyListeners();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    super.value.sort(compare);
    notifyListeners();
  }

  @override
  bool any(bool test(T element)) => super.value.any(test);

  @override
  List<E> cast<E>() => super.value.cast<E>();

  @override
  bool contains(Object? element) => super.value.contains(element);

  @override
  T elementAt(int index) => super.value.elementAt(index);

  @override
  bool every(bool test(T element)) => super.value.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> f(T element)) => super.value.expand(f);

  @override
  T get first => super.value.first;

  @override
  set first(T element) {
    if (isEmpty) {
      throw RangeError.index(0, this);
    }
    this[0] = element;
  }

  @override
  T firstWhere(bool test(T element), {T Function()? orElse}) =>
      super.value.firstWhere(test, orElse: orElse);

  @override
  E fold<E>(E initialValue, E combine(E previousValue, T element)) =>
      super.value.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => super.value.followedBy(other);

  @override
  void forEach(void f(T element)) => super.value.forEach(f);

  @override
  bool get isEmpty => super.value.isEmpty;

  @override
  bool get isNotEmpty => super.value.isNotEmpty;

  @override
  Iterator<T> get iterator => super.value.iterator;

  @override
  String join([String separator = ""]) => super.value.join(separator);

  @override
  T get last => super.value.last;

  @override
  set last(T element) {
    if (isEmpty) {
      throw RangeError.index(0, this);
    }
    this[length - 1] = element;
  }

  @override
  T lastWhere(bool test(T element), {T Function()? orElse}) =>
      super.value.lastWhere(test, orElse: orElse);

  @override
  int get length => super.value.length;

  @override
  Iterable<E> map<E>(E f(T e)) => super.value.map(f);

  @override
  T reduce(T combine(T value, T element)) => super.value.reduce(combine);

  @override
  T get single => super.value.single;

  @override
  T singleWhere(bool test(T element), {T Function()? orElse}) =>
      super.value.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int n) => super.value.skip(n);

  @override
  Iterable<T> skipWhile(bool test(T value)) => super.value.skipWhile(test);

  @override
  Iterable<T> take(int n) => super.value.take(n);

  @override
  Iterable<T> takeWhile(bool test(T value)) => super.value.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) =>
      super.value.toList(growable: growable);

  @override
  Set<T> toSet() => super.value.toSet();

  @override
  Iterable<T> where(bool test(T element)) => super.value.where(test);

  @override
  Iterable<E> whereType<E>() => super.value.whereType<E>();

  @override
  Map<int, T> asMap() => super.value.asMap();

  @override
  Iterable<T> getRange(int start, int end) => super.value.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) =>
      super.value.indexOf(element, start);

  @override
  int indexWhere(bool test(T element), [int start = 0]) =>
      super.value.indexWhere(test, start);

  @override
  int lastIndexOf(T element, [int? start]) =>
      super.value.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool test(T element), [int? start]) =>
      super.value.lastIndexWhere(test, start);

  @override
  List<T> sublist(int start, [int? end]) => super.value.sublist(start, end);
}
