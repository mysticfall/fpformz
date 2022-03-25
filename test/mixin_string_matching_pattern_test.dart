import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class AlphanumericInput extends StringFormInput<String, ValidationError>
    with StringMatchingPattern, NonEmptyString {
  const AlphanumericInput.pristine(name, value) : super.pristine(name, value);

  const AlphanumericInput.dirty(name, value) : super.dirty(name, value);

  @override
  RegExp get pattern => RegExp(r'^[a-zA-Z0-9]+$');

  @override
  Either<ValidationError, String> validate(String value) =>
      super.validate(value).bind((v) => v.contains('admin')
          ? Either.left(
              ValidationError(name, 'ID contains a disallowed string.'))
          : Either.of(v));

  @override
  String convert(String value) => value;
}

void main() {
  group('AlphanumericInput', () {
    test("'pristine' should create an input instance in pristine state", () {
      final input = AlphanumericInput.pristine('id', 'fpformz1234');

      expect(input.name, 'id');
      expect(input.value, 'fpformz1234');
      expect(input.isPristine, true);
    });

    test("'dirty' should create an input instance in a dirty state", () {
      final input = AlphanumericInput.dirty('id', 'fpformz1234');

      expect(input.name, 'id');
      expect(input.value, 'fpformz1234');
      expect(input.isPristine, false);
    });

    test("'validate' should return Right(value) for a valid input", () {
      final input = AlphanumericInput.dirty('id', 'fpformz1234');

      expect(input.result, Either.of('fpformz1234'));
    });

    test("'validate' should return Left(ValidationError) for an invalid input",
        () {
      final input = AlphanumericInput.dirty('id', 'bad!@#id');

      expect(input.result,
          Either.left(ValidationError('id', '"bad!@#id" is not a valid value.')));
    });

    test("should allow overriding 'validate'", () {
      final input = AlphanumericInput.dirty('id', 'admin1234');

      expect(
          input.result,
          Either.left(
              ValidationError('id', 'ID contains a disallowed string.')));
    });

    test("should work with other mixins", () {
      final input = AlphanumericInput.dirty('id', '');

      expect(
          input.result, Either.left(ValidationError('id', 'Please enter id.')));
    });
  });
}
