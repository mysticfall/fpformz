import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'util.dart';
import 'validate.dart';

/// {@template form_input}
/// A [FormInput] represents the value of a single form input field.
/// It contains information about the [value] as well as validity ([result]).
///
/// [FormInput] should be extended to define custom [FormInput] instances.
///
/// ```dart
/// class AgeInput extends FormInput<int, String, ValidationError> {
///   const AgeInput.pristine({String value = ''}) : super.pristine(value);
///   const AgeInput.dirty({String value = ''}) : super.dirty(value);
///
///   Either<ValidationError, int> validate(String value) =>
///     Either.tryCatch(() => int.parse(value),
///       (e, s) => ValidationError(name, '$name should be a number.'));
/// }
/// ```
/// {@endtemplate}
@immutable
abstract class FormInput<V, I, E extends ValidationError>
    implements Validatable<V, E>, Validator<V, I, E> {
  const FormInput._(this.name, this.value, {this.isPristine = true}) : super();

  /// Constructor which creates a `pristine` [FormInput] with a given value.
  const FormInput.pristine(String id, I value) : this._(id, value);

  /// Constructor which creates a `dirty` [FormInput] with a given value.
  const FormInput.dirty(String id, I value)
      : this._(id, value, isPristine: false);

  final String name;

  /// The value of the given [FormInput].
  final I value;

  /// If the [FormInput] is in pristine state (hasn't been touched/modified).
  /// Typically when the `FormInput` is initially created,
  /// it is created using the `FormInput.pristine` constructor to
  /// signify that the user has not modified it.
  ///
  /// For subsequent changes (in response to user input), the
  /// `FormInput.dirty` constructor should be used to signify that
  /// the `FormInput` has been manipulated.
  @override
  final bool isPristine;

  @override
  Either<E, V> get result => validate(value);

  @override
  int get hashCode => Object.hashAll([value, isPristine]);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FormInput<V, I, E> &&
        other.value == value &&
        other.isPristine == isPristine;
  }

  @override
  String toString() =>
      "FormInput<$V, $I, $E>.${isPristine ? 'pristine' : 'dirty'}(value: $value)";
}

@immutable
abstract class BaseFormInput<V, I, E extends ValidationError>
    extends FormInput<V, I, E> {
  const BaseFormInput.pristine(super.id, super.value) : super.pristine();

  const BaseFormInput.dirty(super.id, super.value) : super.dirty();

  V convert(I value);

  @override
  Either<E, V> validate(I value) => Either.of(convert(value));
}

/// A convenient base class for string-based input, which covers most of
/// the practical use cases.
@immutable
abstract class StringFormInput<V, E extends ValidationError>
    extends BaseFormInput<V, String, E> {
  const StringFormInput.pristine(super.id, super.value) : super.pristine();

  const StringFormInput.dirty(super.id, super.value) : super.dirty();
}

class GenericRequiredInput<V> extends FormInput<V, V?, ValidationError> {
  const GenericRequiredInput.pristine(String name, {V? value})
      : super.pristine(name, value);

  const GenericRequiredInput.dirty(String name, {V? value})
      : super.dirty(name, value);

  GenericRequiredInput<V> update(V? value) =>
      GenericRequiredInput.dirty(name, value: value);

  ValidationError whenEmpty(V? value) =>
      ValidationError(name, '${name.capitalise()} cannot be empty.');

  @override
  Either<ValidationError, V> validate(V? value) => Either.fromOption(
      Option.fromNullable(value).filter((t) => t is! Iterable || t.isNotEmpty),
      () => whenEmpty(value));
}
