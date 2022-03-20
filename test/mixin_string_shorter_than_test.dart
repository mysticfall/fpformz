import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class NameInput extends StringFormInput<String, ValidationError>
    with StringShorterThan, NonEmptyString {
  const NameInput.pristine(name, value) : super.pristine(name, value);

  const NameInput.dirty(name, value) : super.dirty(name, value);

  @override
  Either<ValidationError, String> validate(String value) => value.contains(' ')
      ? Either.left(ValidationError(name, 'The name contains a space.'))
      : super.validate(value);

  @override
  int get maxLength => 15;

  @override
  String convert(String value) => value;
}

void main() {
  group('StringShorterThan', () {
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
      final input = NameInput.dirty('name', 'Zopittybop-Bop-Bop');

      expect(
          input.result,
          Either.left(ValidationError(
              'name', 'Name must be no longer than 15 letters long.')));
    });

    test("should allow overriding 'validate'", () {
      final input = NameInput.dirty('name', 'Xanthias A.');

      expect(input.result,
          Either.left(ValidationError('name', 'The name contains a space.')));
    });

    test("should work with other mixins", () {
      final input = NameInput.dirty('name', '');

      expect(input.result,
          Either.left(ValidationError('name', 'Please enter name.')));
    });
  });
}
