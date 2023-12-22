import 'package:meta/meta.dart';

/// $NodeExtraStorage Singleton class
@internal
class $NodeExtraStorage {
  factory $NodeExtraStorage() => _internalSingleton;
  $NodeExtraStorage._internal() : _storage = <String, Map<String, Object?>?>{};
  static final $NodeExtraStorage _internalSingleton =
      $NodeExtraStorage._internal();

  final Map<String, Map<String, Object?>?> _storage;

  @internal
  Map<String, Object?> getByKey(String key) =>
      _storage[key] ??= <String, Object?>{};

  @internal
  void removeByKey(String key) => _storage.remove(key);

  @internal
  void removeByKeys(Set<String> keys) => keys.forEach(_storage.remove);

  @internal
  void removeEverythingExcept(Set<String> keys) =>
      removeByKeys(_storage.keys.toSet().difference(keys));
}
