// ignore_for_file: parameter_assignments

import 'package:meta/meta.dart';

/// Jenkins Hash Functions
///
/// A function that returns a hash code for the given list of [props].
/// https://en.wikipedia.org/wiki/Jenkins_hash_function
///
/// {@nodoc}
@internal
int jenkinsHash(Object? object) =>
    _jenkinsFinish(object == null ? 0 : _jenkinsCombine(0, object));

/// Jenkins Hash Functions
///
/// {@nodoc}
@internal
int jenkinsHashAll(Iterable<Object?>? objects) {
  if (objects == null) return _jenkinsFinish(0);
  var hash = 0;
  for (final object in objects) {
    hash = _jenkinsCombine(hash, object);
  }
  return _jenkinsFinish(hash);
}

/// Jenkins Hash Functions (Combine)
///
/// {@nodoc}
int _jenkinsCombine(int hash, Object? object) {
  int objectHash;
  if (object is Map) {
    final entries = object.entries.toList(growable: false)
      ..sort((a, b) => a.key.hashCode.compareTo(b.key.hashCode));
    objectHash = Object.hashAll(entries);
  } else if (object is Set) {
    final entries = object.toList(growable: false)
      ..sort((a, b) => a.hashCode.compareTo(b.hashCode));
    objectHash = Object.hashAll(entries);
  }
  if (object is Iterable) {
    for (final value in object) {
      hash = hash ^ _jenkinsCombine(hash, value);
    }
    return hash ^ object.length;
  } else {
    objectHash = object.hashCode;
  }
  hash = 0x1fffffff & (hash + objectHash);
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
/// {@nodoc}
int _jenkinsFinish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}
