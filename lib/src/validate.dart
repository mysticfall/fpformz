import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

@immutable
abstract class Validatable<V, E extends ValidationError> {
  /// If the [Validatable] is in pristine state (hasn't been touched/modified).
  bool get isPristine;

  Either<E, V> get result;
}

extension ValidatableExtension<V, E extends ValidationError>
    on Validatable<V, E> {
  bool get isValid => result is Right;

  V? get resultOrNull => result.getRight().toNullable();

  Option<E> get error => result.getLeft();

  E? get errorOrNull => error.toNullable();
}

@immutable
abstract class Validator<V, I, E extends ValidationError> {
  /// A pure function that validates the given [value] and returns the result as
  /// `Either<E, V>`, encoding either a corresponding model value or an error message.
  Either<E, V> validate(I value);
}

@immutable
class ValidationError {
  final String name;

  final String message;

  const ValidationError(this.name, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          message == other.message;

  @override
  int get hashCode => name.hashCode ^ message.hashCode;

  @override
  String toString() {
    return 'ValidationError{name: $name, message: $message}';
  }
}
