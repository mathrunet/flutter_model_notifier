part of model_notifier;

final _container = ProviderContainer();

/// Load the provider.
///
/// It is freely available from outside the widget.
///
/// Please specify the provider you want to load in [provider].
Result readProvider<Result>(ProviderBase<Object?, Result> provider) {
  return _container.read(provider);
}
