import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class AgeInput extends FormInput<int, String, ValidationError> {
  const AgeInput.pristine(name, value) : super.pristine(name, value);

  const AgeInput.dirty(name, value) : super.dirty(name, value);

  Either<ValidationError, String> validateIsNonEmpty(String value) =>
      Either.fromPredicate(value, (v) => v.isNotEmpty,
          (v) => ValidationError(name, 'Age cannot be empty.'));

  Either<ValidationError, int> validateIsNumber(String value) =>
      Either.tryCatch(() => int.parse(value),
          (e, s) => ValidationError(name, 'Age is not a number.'));

  @override
  Either<ValidationError, int> validate(String value) =>
      validateIsNonEmpty(value).bind(validateIsNumber);
}

void main() {
  group('FormInput', () {
    test("'pristine' should create an input instance in pristine state", () {
      final input = AgeInput.pristine('age', '23');

      expect(input.name, 'age');
      expect(input.value, '23');
      expect(input.isPristine, true);
    });

    test("'dirty' should create an input instance in a dirty state", () {
      final input = AgeInput.dirty('age', '23');

      expect(input.name, 'age');
      expect(input.value, '23');
      expect(input.isPristine, false);
    });

    test("'validate' should return Right(value) for a valid input", () {
      final input = AgeInput.dirty('age', '23');

      expect(input.validate('45'), Either.of(45));
    });

    test("'validate' should return Left(ValidationError) for an invalid input",
        () {
      final input = AgeInput.dirty('age', '');

      expect(input.result,
          Either.left(ValidationError('age', 'Age cannot be empty.')));
    });

    test("'isValid' should return true for a valid input", () {
      final input = AgeInput.dirty('age', '23');

      expect(input.isValid, true);
    });

    test("'isValid' should return false for an invalid input", () {
      final input = AgeInput.dirty('age', '');

      expect(input.isValid, false);
    });

    test("'result' should return the validated input value as Either<E, V>", () {
      final valid = AgeInput.dirty('age', '23');
      final invalid = AgeInput.dirty('age', 'abc');

      expect(valid.result, Either.of(23));
      expect(invalid.result, Either.left(ValidationError('age', 'Age is not a number.')));
    });

    test("'resultOrNull' should return the validated input value as V?", () {
      final valid = AgeInput.dirty('age', '23');
      final invalid = AgeInput.dirty('age', 'abc');

      expect(valid.resultOrNull, 23);
      expect(invalid.resultOrNull, null);
    });

    test("'error' should return None for a valid input", () {
      final input = AgeInput.dirty('age', '23');

      expect(input.error, None());
    });

    test("'error' should return Some(ValidationError) for an invalid input",
        () {
      final input = AgeInput.dirty('age', 'abc');

      expect(input.error, Some(ValidationError('age', 'Age is not a number.')));
    });

    test("'errorOrNull should return null for a valid input", () {
      final input = AgeInput.dirty('age', '23');

      expect(input.errorOrNull, null);
    });

    test("'errorOrNull' should return a ValidationError for an invalid input",
        () {
      final input = AgeInput.dirty('age', 'abc');

      expect(input.errorOrNull, ValidationError('age', 'Age is not a number.'));
    });
  });
}
