part of model_notifier;

/// {@macro riverpod.changenotifierprovider}
@sealed
class ModelProvider<T extends Model> extends AlwaysAliveProviderBase<T, T> {
  /// {@macro riverpod.changenotifierprovider}
  ModelProvider(
    Create<T, ProviderReference> create, {
    String? name,
  }) : super(create, name);

  /// {@macro riverpod.family}
  static const family = ModelProviderFamilyBuilder();

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeModelProviderBuilder();

  @override
  _ModelProviderState<T> createState() => _ModelProviderState();
}

@sealed
class _ModelProviderState<T extends Model> = ProviderStateBase<T, T>
    with _ModelProviderStateMixin<T>;

/// {@template riverpod.changenotifierprovider.family}
/// A class that allows building a [ModelProvider] from an external parameter.
/// {@endtemplate}
@sealed
class ModelProviderFamily<T extends Model, A>
    extends Family<T, T, A, ProviderReference, ModelProvider<T>> {
  /// {@macro riverpod.changenotifierprovider.family}
  ModelProviderFamily(
    T Function(ProviderReference ref, A a) create, {
    String? name,
  }) : super(create, name);

  @override
  ModelProvider<T> create(
    A value,
    T Function(ProviderReference ref, A param) builder,
    String? name,
  ) {
    return ModelProvider((ref) => builder(ref, value), name: name);
  }
}

/// {@template riverpod.changenotifierprovider}
/// Creates a [Model] and subscribes to it.
///
/// Note: By using Riverpod, [Model] will no-longer be O(N^2) for
/// dispatching notifications, but instead O(N)
/// {@endtemplate}
mixin _ModelProviderStateMixin<T extends Model?> on ProviderStateBase<T, T> {
  @override
  void valueChanged({T? previous}) {
    if (createdValue == previous) {
      return;
    }
    previous?.removeListener(_listener);
    previous?.dispose();
    exposedValue = createdValue;
    createdValue?.addListener(_listener);
  }

  void _listener() {
    exposedValue = createdValue;
  }

  @override
  void dispose() {
    createdValue?.removeListener(_listener);
    createdValue?.dispose();
    super.dispose();
  }
}

/// Builds a [ModelProvider].
class ModelProviderBuilder {
  /// Builds a [ModelProvider].
  const ModelProviderBuilder();

  /// {@template riverpod.autoDispose}
  /// Marks the provider as automatically disposed when no-longer listened.
  ///
  /// Some typical use-cases:
  ///
  /// - Combined with [StreamProvider], this can be used as a mean to keep
  ///   the connection with Firebase alive only when truly needed (to reduce costs).
  /// - Automatically reset a form state when leaving the screen.
  /// - Automatically retry HTTP requests that failed when the user exit and
  ///   re-enter the screen.
  /// - Cancel HTTP requests if the user leaves a screen before the request completed.
  ///
  /// Marking a provider with `autoDispose` also adds an extra property on `ref`: `maintainState`.
  ///
  /// The `maintainState` property is a boolean (`false` by default) that allows
  /// the provider to tell Riverpod if the state of the provider should be preserved
  /// even if no-longer listened.
  ///
  /// A use-case would be to set this flag to `true` after an HTTP request have
  /// completed:
  ///
  /// ```dart
  /// final myProvider = FutureProvider.autoDispose((ref) async {
  ///   final response = await httpClient.get(...);
  ///   ref.maintainState = true;
  ///   return response;
  /// });
  /// ```
  ///
  /// This way, if the request failed and the UI leaves the screen then re-enters
  /// it, then the request will be performed again.
  /// But if the request completed successfully, the state will be preserved
  /// and re-entering the screen will not trigger a new request.
  ///
  /// It can be combined with `ref.onDispose` for more advanced behaviors, such
  /// as cancelling pending HTTP requests when the user leaves a screen.
  /// For example, modifying our previous snippet and using `dio`, we would have:
  ///
  /// ```diff
  /// final myProvider = FutureProvider.autoDispose((ref) async {
  /// + final cancelToken = CancelToken();
  /// + ref.onDispose(() => cancelToken.cancel());
  ///
  /// + final response = await dio.get('path', cancelToken: cancelToken);
  /// - final response = await dio.get('path');
  ///   ref.maintainState = true;
  ///   return response;
  /// });
  /// ```
  /// {@endtemplate}
  ModelProvider<T> call<T extends Model>(
    T Function(ProviderReference ref) create, {
    String? name,
  }) {
    return ModelProvider(create, name: name);
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeModelProviderBuilder get autoDispose {
    return const AutoDisposeModelProviderBuilder();
  }

  /// {@template riverpod.family}
  /// A group of providers that builds their value from an external parameter.
  ///
  /// Families can be useful to connect a provider with values that it doesn't
  /// have access to. For example:
  ///
  /// - Allowing a "title provider" access the `Locale`
  ///
  ///   ```dart
  ///   final titleFamily = Provider.family<String, Locale>((ref, locale) {
  ///     if (locale == const Locale('en')) {
  ///       return 'English title';
  ///     } else if (locale == const Locale('fr')) {
  ///       return 'Titre Français';
  ///     }
  ///   });
  ///
  ///   // ...
  ///
  ///   @override
  ///   Widget build(BuildContext context, ScopedReader watch) {
  ///     final locale = Localizations.localeOf(context);
  ///
  ///     // Obtains the title based on the current Locale.
  ///     // Will automatically update the title when the Locale changes.
  ///     final title = watch(titleFamily(locale));
  ///
  ///     return Text(title);
  ///   }
  ///   ```
  ///
  /// - Have a "user provider" that receives the user ID as parameter
  ///
  ///   ```dart
  ///   final userFamily = FutureProvider.family<User, int>((ref, userId) async {
  ///     final userRepository = ref.read(userRepositoryProvider);
  ///     return await userRepository.fetch(userId);
  ///   });
  ///
  ///   // ...
  ///
  ///   @override
  ///   Widget build(BuildContext context, ScopedReader watch) {
  ///     int userId; // Read the user ID from somewhere
  ///
  ///     // Read and potentially fetch the user with id `userId`.
  ///     // When `userId` changes, this will automatically update the UI
  ///     // Similarly, if two widgets tries to read `userFamily` with the same `userId`
  ///     // then the user will be fetched only once.
  ///     final user = watch(userFamily(userId));
  ///
  ///     return user.when(
  ///       data: (user) => Text(user.name),
  ///       loading: () => const CircularProgressIndicator(),
  ///       error: (err, stack) => const Text('error'),
  ///     );
  ///   }
  ///   ```
  ///
  /// - Connect a provider with another provider without having a direct reference on it.
  ///
  ///   ```dart
  ///   final repositoryProvider = Provider.family<String, FutureProvider<Configurations>>((ref, configurationsProvider) {
  ///     // Read a provider without knowing what that provider is.
  ///     final configurations = await ref.read(configurationsProvider.future);
  ///     return Repository(host: configurations.host);
  ///   });
  ///   ```
  ///
  /// ## Usage
  ///
  /// The way families works is by adding an extra parameter to the provider.
  /// This parameter can then be freely used in our provider to create some state.
  ///
  /// For example, we could combine `family` with [FutureProvider] to fetch
  /// a `Message` from its ID:
  ///
  /// ```dart
  /// final messagesFamily = FutureProvider.family<Message, String>((ref, id) async {
  ///   return dio.get('http://my_api.dev/messages/$id');
  /// });
  /// ```
  ///
  /// Then, when using our `messagesFamily` provider, the syntax is slightly modified.
  /// The usual:
  ///
  /// ```dart
  /// Widget build(BuildContext, ScopedReader watch) {
  ///   // Error – messagesFamily is not a provider
  ///   final response = watch(messagesFamily);
  /// }
  /// ```
  ///
  /// will not work anymore.
  /// Instead, we need to pass a parameter to `messagesFamily`:
  ///
  /// ```dart
  /// Widget build(BuildContext, ScopedReader watch) {
  ///   final response = watch(messagesFamily('id'));
  /// }
  /// ```
  ///
  /// **NOTE**: It is totally possible to use a family with different parameters
  /// simultaneously. For example, we could use a `titleFamily` to read both
  /// the french and english translations at the same time:
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context, ScopedReader watch) {
  ///   final frenchTitle = watch(titleFamily(const Locale('fr')));
  ///   final englishTitle = watch(titleFamily(const Locale('en')));
  ///
  ///   return Text('fr: $frenchTitle en: $englishTitle');
  /// }
  /// ```
  ///
  /// # Parameter restrictions
  ///
  /// For families to work correctly, it is critical for the parameter passed to
  /// a provider to have a consistent `hashCode` and `==`.
  ///
  /// Ideally the parameter should either be a primitive (bool/int/double/String),
  /// a constant (providers), or an immutable object that override `==` and `hashCode`.
  ///
  ///
  /// - **PREFER** using `family` in combination with `autoDispose` if the
  ///   parameter passed to providers is a complex object:
  ///
  ///   ```dart
  ///   final example = Provider.autoDispose.family<Value, ComplexParameter>((ref, param) {
  ///   });
  ///   ```
  ///
  ///   This ensures that there is no memory leak if the parameter changed and is
  ///   never used again.
  ///
  /// # Passing multiple parameters to a family
  ///
  /// Families have no built-in support for passing multiple values to a provider.
  ///
  /// On the other hand, that value could be _anything_ (as long as it matches with
  /// the restrictions mentioned previously).
  ///
  /// This includes:
  /// - A tuple (using `package:tuple`)
  /// - Objects generated with Freezed/built_value
  /// - Objects based on `package:equatable`
  ///
  /// This includes:
  /// - A tuple (using `package:tuple`)
  /// - Objects generated with Freezed/built_value, such as:
  ///   ```dart
  ///   @freezed
  ///   abstract class MyParameter with _$MyParameter {
  ///     factory MyParameter({
  ///       required int userId,
  ///       required Locale locale,
  ///     }) = _MyParameter;
  ///   }
  ///
  ///   final exampleProvider = Provider.family<Something, MyParameter>((ref, myParameter) {
  ///     print(myParameter.userId);
  ///     print(myParameter.locale);
  ///     // Do something with userId/locale
  ///   });
  ///
  ///   @override
  ///   Widget build(BuildContext context, ScopedReader watch) {
  ///     int userId; // Read the user ID from somewhere
  ///     final locale = Localizations.localeOf(context);
  ///
  ///     final something = watch(
  ///       exampleProvider(MyParameter(userId: userId, locale: locale)),
  ///     );
  ///   }
  ///   ```
  ///
  /// - Objects based on `package:equatable`, such as:
  ///   ```dart
  ///   class MyParameter extends Equatable  {
  ///     factory MyParameter({
  ///       required this.userId,
  ///       requires this.locale,
  ///     });
  ///
  ///     final int userId;
  ///     final Local locale;
  ///
  ///     @override
  ///     List<Object> get props => [userId, locale];
  ///   }
  ///
  ///   final exampleProvider = Provider.family<Something, MyParameter>((ref, myParameter) {
  ///     print(myParameter.userId);
  ///     print(myParameter.locale);
  ///     // Do something with userId/locale
  ///   });
  ///
  ///   @override
  ///   Widget build(BuildContext context, ScopedReader watch) {
  ///     int userId; // Read the user ID from somewhere
  ///     final locale = Localizations.localeOf(context);
  ///
  ///     final something = watch(
  ///       exampleProvider(MyParameter(userId: userId, locale: locale)),
  ///     );
  ///   }
  ///   ```
  /// {@endtemplate}
  ModelProviderFamilyBuilder get family {
    return const ModelProviderFamilyBuilder();
  }
}

/// Builds a [ModelProviderFamily].
class ModelProviderFamilyBuilder {
  /// Builds a [ModelProviderFamily].
  const ModelProviderFamilyBuilder();

  /// {@macro riverpod.family}
  ModelProviderFamily<T, Value> call<T extends Model, Value>(
    T Function(ProviderReference ref, Value value) create, {
    String? name,
  }) {
    return ModelProviderFamily(create, name: name);
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeModelProviderFamilyBuilder get autoDispose {
    return const AutoDisposeModelProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeModelProvider].
class AutoDisposeModelProviderBuilder {
  /// Builds a [AutoDisposeModelProvider].
  const AutoDisposeModelProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeModelProvider<T> call<T extends Model>(
    T Function(AutoDisposeProviderReference ref) create, {
    String? name,
  }) {
    return AutoDisposeModelProvider(create, name: name);
  }

  /// {@macro riverpod.family}
  AutoDisposeModelProviderFamilyBuilder get family {
    return const AutoDisposeModelProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeModelProviderFamily].
class AutoDisposeModelProviderFamilyBuilder {
  /// Builds a [AutoDisposeModelProviderFamily].
  const AutoDisposeModelProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeModelProviderFamily<T, Value> call<T extends Model, Value>(
    T Function(AutoDisposeProviderReference ref, Value value) create, {
    String? name,
  }) {
    return AutoDisposeModelProviderFamily(create, name: name);
  }
}

/// {@macro riverpod.changenotifierprovider}
@sealed
class AutoDisposeModelProvider<T extends Model>
    extends AutoDisposeProviderBase<T, T> {
  /// {@macro riverpod.changenotifierprovider}
  AutoDisposeModelProvider(
    Create<T, AutoDisposeProviderReference> create, {
    String? name,
  }) : super(create, name);

  /// {@macro riverpod.family}
  static const family = ModelProviderFamilyBuilder();

  @override
  _AutoDisposeModelProviderState<T> createState() =>
      _AutoDisposeModelProviderState();
}

@sealed
class _AutoDisposeModelProviderState<T extends Model> = ProviderStateBase<T, T>
    with _ModelProviderStateMixin<T>;

/// {@macro riverpod.changenotifierprovider.family}
@sealed
class AutoDisposeModelProviderFamily<T extends Model, A> extends Family<T, T, A,
    AutoDisposeProviderReference, AutoDisposeModelProvider<T>> {
  /// {@macro riverpod.changenotifierprovider.family}
  AutoDisposeModelProviderFamily(
    T Function(AutoDisposeProviderReference ref, A a) create, {
    String? name,
  }) : super(create, name);

  @override
  AutoDisposeModelProvider<T> create(
    A value,
    T Function(AutoDisposeProviderReference ref, A param) builder,
    String? name,
  ) {
    return AutoDisposeModelProvider(
      (ref) => builder(ref, value),
      name: name,
    );
  }
}
