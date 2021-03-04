part of model_notifier;

class _ProviderManager {
  _ProviderManager._();
  static final Map<int, dynamic> _container = {};

  static Result read<Result>(ProviderBase<Object?, Result> provider) {
    final hashCode = provider.hashCode;
    if (_container.containsKey(hashCode)) {
      return _container[hashCode];
    }
    return _container[hashCode] = ProviderContainer().read(provider);
  }
}
