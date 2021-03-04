part of model_notifier;

Result readProvider<Result>(ProviderBase<Object?, Result> provider) {
  return _ProviderManager.read(provider);
}
