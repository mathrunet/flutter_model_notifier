part of model_notifier;

Result readProvider<Result>(ProviderBase<Object?, Result> provider) {
  return ProviderContainer().read(provider);
}
