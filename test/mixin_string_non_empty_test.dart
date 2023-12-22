import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class NameInput extends StringFormInput<String, ValidationError>
    with NonEmptyString, StringShorterThan {
  const NameInput.pristine(super.name, super.value) : super.pristine();

  const NameInput.dirty(super.name, super.value) : super.dirty();

  @override
  Either<ValidationError, String> validate(String value) => value.contains(' ')
      ? Either.left(ValidationError(name, 'The name contains a space.'))
      : super.validate(value);

  @override
  int get maxLength => 20;

  @override
  ValidationError whenTooLong(String value) =>
      ValidationError(name, 'Is that even a name?');

  @override
  String convert(String value) => value;
}

void main() {
  group('NonEmptyString', () {
    test("'pristine' should create an input instance in pristine state", () {
      final input = NameInput.pristine('name', 'Anna');

      expect(input.name, 'name');
      expect(input.value, 'Anna');
      expect(input.isPristine, true);
    });

    test("'dirty' should create an input instance in a dirty state", () {
      final input = NameInput.dirty('name', 'Anna');

      expect(input.name, 'name');
      expect(input.value, 'Anna');
      expect(input.isPristine, false);
    });

    test("'validate' should return Right(value) for a valid input", () {
      final input = NameInput.dirty('name', 'Anna');

      expect(input.result, Either.of('Anna'));
    });

    test("'validate' should return Left(ValidationError) for an invalid input",
        () {
      final input = NameInput.dirty('name', '');

      expect(input.result,
          Either.left(ValidationError('name', 'Please enter name.')));
    });

    test("should allow overriding 'validate'", () {
      final input = NameInput.dirty('name', 'Xanthias A.');

      expect(input.result,
          Either.left(ValidationError('name', 'The name contains a space.')));
    });

    test("should work with other mixins", () {
      final input =
          NameInput.dirty('name', 'Supercalifragilisticexpialidocious');

      expect(input.result,
          Either.left(ValidationError('name', 'Is that even a name?')));
    });
  });
}
