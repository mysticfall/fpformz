import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'input.dart';
import 'util.dart';
import 'validate.dart';

@immutable
mixin NonEmptyString<V> on FormInput<V, String, ValidationError> {
  ValidationError get whenEmpty => ValidationError(name, 'Please enter $name.');

  @override
  Either<ValidationError, V> validate(String value) =>
      value.isEmpty ? Either.left(whenEmpty) : super.validate(value);
}

@immutable
mixin StringLongerThan<V> on FormInput<V, String, ValidationError> {
  int get minLength;

  ValidationError get whenTooShort => ValidationError(
      name, '${name.capitalise()} must be at least $minLength letters long.');

  @override
  Either<ValidationError, V> validate(String value) => value.length < minLength
      ? Either.left(whenTooShort)
      : super.validate(value);
}

@immutable
mixin StringShorterThan<V> on FormInput<V, String, ValidationError> {
  int get maxLength;

  ValidationError get whenTooLong => ValidationError(name,
      '${name.capitalise()} must be no longer than $maxLength letters long.');

  @override
  Either<ValidationError, V> validate(String value) => value.length > maxLength
      ? Either.left(whenTooLong)
      : super.validate(value);
}

@immutable
mixin StringMatchingPattern<V> on FormInput<V, String, ValidationError> {
  RegExp get pattern;

  ValidationError get whenInvalid =>
      ValidationError(name, '$name is not a valid value.');

  @override
  Either<ValidationError, V> validate(String value) => pattern.hasMatch(value)
      ? super.validate(value)
      : Either.left(whenInvalid);
}

@immutable
mixin EmailString<V> on FormInput<V, String, ValidationError>
    implements StringMatchingPattern<V> {
  // See: https://html.spec.whatwg.org/multipage/input.html#e-mail-state-%28type=email%29
  static final _pattern = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");

  @override
  RegExp get pattern => _pattern;

  @override
  ValidationError get whenInvalid =>
      ValidationError(name, 'Value is not a valid email address.');

  @override
  Either<ValidationError, V> validate(String value) => _pattern.hasMatch(value)
      ? super.validate(value)
      : Either.left(whenInvalid);
}
