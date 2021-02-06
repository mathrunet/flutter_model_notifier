part of model_notifier;

class ListNotifier<T extends Listenable> extends ChangeNotifier
    implements List<T> {
  ListNotifier([List<T> listenables = const []]) : _listenables = listenables {
    _listenables.forEach((e) => e.addListener(notifyListeners));
  }

  final List<T> _listenables;

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    _listenables.forEach((e) => e.removeListener(notifyListeners));
    _listenables.clear();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (_listenables == other) {
      return true;
    }
    if (other is ListNotifier) {
      if (_listenables.length != other.length) {
        return false;
      }
      for (int i = 0; i < _listenables.length; i++) {
        if (_listenables[i] != other[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _listenables.hashCode;

  @override
  String toString() => IterableBase.iterableToShortString(this, "(", ")");

  @override
  set length(int value) {
    _listenables.length = value;
    notifyListeners();
  }

  @override
  List<T> operator +(List<T> other) => _listenables + other;

  @override
  T operator [](int index) => _listenables[index];

  @override
  void operator []=(int index, T value) {
    _listenables[index].removeListener(notifyListeners);
    _listenables[index] = value..addListener(notifyListeners);
    notifyListeners();
  }

  @override
  void add(T value) {
    _listenables.add(value..addListener(notifyListeners));
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    iterable.forEach((e) => e.addListener(notifyListeners));
    _listenables.addAll(iterable);
    notifyListeners();
  }

  @override
  void clear() {
    _listenables.forEach((e) => e.removeListener(notifyListeners));
    _listenables.clear();
    notifyListeners();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    _listenables
        .getRange(start, end)
        .forEach((e) => e.removeListener(notifyListeners));
    fillValue?.addListener(notifyListeners);
    _listenables.fillRange(start, end, fillValue);
    notifyListeners();
  }

  @override
  void insert(int index, T element) {
    element.addListener(notifyListeners);
    _listenables.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    iterable.forEach((e) => e.addListener(notifyListeners));
    _listenables.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    if (_listenables.remove(value)) {
      if (value is Listenable) {
        value.removeListener(notifyListeners);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  T removeAt(int index) {
    final value = _listenables.removeAt(index);
    value.removeListener(notifyListeners);
    notifyListeners();
    return value;
  }

  @override
  T removeLast() {
    final value = _listenables.removeLast();
    value.removeListener(notifyListeners);
    notifyListeners();
    return value;
  }

  @override
  void removeRange(int start, int end) {
    _listenables
        .getRange(start, end)
        .forEach((e) => e.removeListener(notifyListeners));
    _listenables.removeRange(start, end);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _listenables.removeWhere((e) {
      if (!test(e)) {
        return false;
      }
      e.removeListener(notifyListeners);
      return true;
    });
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacement) {
    _listenables
        .getRange(start, end)
        .forEach((e) => e.removeListener(notifyListeners));
    replacement.forEach((e) => e.addListener(notifyListeners));
    _listenables.replaceRange(start, end, replacement);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _listenables.retainWhere((e) {
      if (test(e)) {
        return true;
      }
      e.removeListener(notifyListeners);
      return false;
    });
    notifyListeners();
  }

  @override
  Iterable<T> get reversed {
    final iterable = _listenables.reversed;
    notifyListeners();
    return iterable;
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    _listenables
        .getRange(index, index + iterable.length)
        .forEach((e) => e.removeListener(notifyListeners));
    iterable.forEach((e) => e.addListener(notifyListeners));
    _listenables.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    int i = 0;
    _listenables
        .getRange(start, end)
        .forEach((e) => e.removeListener(notifyListeners));
    iterable.forEach((element) {
      if (i >= skipCount && (end - start) + skipCount >= i) {
        element.addListener(notifyListeners);
      }
      i++;
    });
    _listenables.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _listenables.shuffle(random);
    notifyListeners();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _listenables.sort(compare);
    notifyListeners();
  }

  @override
  bool any(bool test(T element)) => _listenables.any(test);

  @override
  List<E> cast<E>() => _listenables.cast<E>();

  @override
  bool contains(Object? element) => _listenables.contains(element);

  @override
  T elementAt(int index) => _listenables.elementAt(index);

  @override
  bool every(bool test(T element)) => _listenables.every(test);

  @override
  Iterable<E> expand<E>(Iterable<E> f(T element)) => _listenables.expand(f);

  @override
  T get first => _listenables.first;

  @override
  set first(T element) {
    if (isEmpty) {
      throw RangeError.index(0, this);
    }
    this[0] = element;
  }

  @override
  T firstWhere(bool test(T element), {T Function()? orElse}) =>
      _listenables.firstWhere(test, orElse: orElse);

  @override
  E fold<E>(E initialValue, E combine(E previousValue, T element)) =>
      _listenables.fold(initialValue, combine);

  @override
  Iterable<T> followedBy(Iterable<T> other) => _listenables.followedBy(other);

  @override
  void forEach(void f(T element)) => _listenables.forEach(f);

  @override
  bool get isEmpty => _listenables.isEmpty;

  @override
  bool get isNotEmpty => _listenables.isNotEmpty;

  @override
  Iterator<T> get iterator => _listenables.iterator;

  @override
  String join([String separator = ""]) => _listenables.join(separator);

  @override
  T get last => _listenables.last;

  @override
  set last(T element) {
    if (isEmpty) {
      throw RangeError.index(0, this);
    }
    this[length - 1] = element;
  }

  @override
  T lastWhere(bool test(T element), {T Function()? orElse}) =>
      _listenables.lastWhere(test, orElse: orElse);

  @override
  int get length => _listenables.length;

  @override
  Iterable<E> map<E>(E f(T e)) => _listenables.map(f);

  @override
  T reduce(T combine(T value, T element)) => _listenables.reduce(combine);

  @override
  T get single => _listenables.single;

  @override
  T singleWhere(bool test(T element), {T Function()? orElse}) =>
      _listenables.singleWhere(test, orElse: orElse);

  @override
  Iterable<T> skip(int n) => _listenables.skip(n);

  @override
  Iterable<T> skipWhile(bool test(T value)) => _listenables.skipWhile(test);

  @override
  Iterable<T> take(int n) => _listenables.take(n);

  @override
  Iterable<T> takeWhile(bool test(T value)) => _listenables.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) =>
      _listenables.toList(growable: growable);

  @override
  Set<T> toSet() => _listenables.toSet();

  @override
  Iterable<T> where(bool test(T element)) => _listenables.where(test);

  @override
  Iterable<E> whereType<E>() => _listenables.whereType<E>();

  @override
  Map<int, T> asMap() => _listenables.asMap();

  @override
  Iterable<T> getRange(int start, int end) => _listenables.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) =>
      _listenables.indexOf(element, start);

  @override
  int indexWhere(bool test(T element), [int start = 0]) =>
      _listenables.indexWhere(test, start);

  @override
  int lastIndexOf(T element, [int? start]) =>
      _listenables.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool test(T element), [int? start]) =>
      _listenables.lastIndexWhere(test, start);

  @override
  List<T> sublist(int start, [int? end]) => _listenables.sublist(start, end);
}
