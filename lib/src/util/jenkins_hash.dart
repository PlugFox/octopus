// ignore_for_file: parameter_assignments

import 'package:meta/meta.dart';

/// Jenkins Hash Functions
///
/// A function that returns a hash code for the given list of [props].
/// https://en.wikipedia.org/wiki/Jenkins_hash_function
///
@internal
int jenkinsHash(Object? object) => object is Iterable
    ? jenkinsHashAll(object)
    : _jenkinsFinish(object == null ? 0 : _jenkinsCombine(0, object));

/// Jenkins Hash Functions
///
@internal
int jenkinsHashAll(Iterable<Object?>? objects) {
  if (objects == null) return _jenkinsFinish(0);
  var hash = 0;
  for (final object in objects) {
    hash = _jenkinsCombine(hash, object);
  }
  hash ^= objects.length;
  return _jenkinsFinish(hash);
}

/// Jenkins Hash Functions (Combine)
///
int _jenkinsCombine(int hash, Object? object) {
  if (object is Map) {
    final entries = object.entries.toList(growable: false)
      ..sort((a, b) => a.key.hashCode.compareTo(b.key.hashCode));
    for (final entry in entries) {
      hash ^= _jenkinsCombine(hash, [entry.key, entry.value]);
    }
    return hash ^ entries.length;
  } else if (object is Set) {
    object = object.toList(growable: false)
      ..sort((a, b) => a.hashCode.compareTo(b.hashCode));
  }
  if (object is Iterable) {
    for (final value in object) {
      hash ^= _jenkinsCombine(hash, value);
    }
    return hash ^ object.length;
  }

  hash = 0x1fffffff & (hash + object.hashCode);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

/// Jenkins Hash Functions (Finish)
///
/// Здесь применяются дополнительные операции битового "И" (&)
/// с магическими числами (0x1fffffff, 0x03ffffff, 0x00003fff)
/// для ограничения размера результата.
/// Это гарантирует, что хеш не выйдет за пределы определенного диапазона,
/// уменьшая вероятность переполнения
/// и обеспечивая более равномерное распределение.
///
int _jenkinsFinish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
