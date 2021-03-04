part of model_notifier;

final _container = ProviderContainer();

Result readProvider<Result>(ProviderBase<Object?, Result> provider) {
  return _container.read(provider);
}
