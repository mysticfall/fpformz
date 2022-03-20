import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class Email {
  final String user;
  final String host;

  const Email(this.user, this.host);

  factory Email.parse(String address) {
    final segments = address.split('@');
    return Email(segments[0], segments[1]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email && runtimeType == other.runtimeType && host == other.host;

  @override
  int get hashCode => host.hashCode;
}

class EmailInput extends StringFormInput<Email, ValidationError>
    with EmailString, NonEmptyString {
  const EmailInput.pristine(name, value) : super.pristine(name, value);

  const EmailInput.dirty(name, value) : super.dirty(name, value);

  @override
  Either<ValidationError, Email> validate(String value) =>
      super.validate(value).bind((e) => e.host == 'some.shady.host'
          ? Either.left(ValidationError(name, 'Go away spammer!'))
          : Either.of(e));

  @override
  Email convert(String value) => Email.parse(value);
}

void main() {
  group('EmailInput', () {
    test("'pristine' should create an input instance in pristine state", () {
      final input =
          EmailInput.pristine('email', 'somebody@somewhere.out.there');

      expect(input.name, 'email');
      expect(input.value, 'somebody@somewhere.out.there');
      expect(input.isPristine, true);
    });

    test("'dirty' should create an input instance in a dirty state", () {
      final input = EmailInput.dirty('email', 'somebody@somewhere.out.there');

      expect(input.name, 'email');
      expect(input.value, 'somebody@somewhere.out.there');
      expect(input.isPristine, false);
    });

    test("'validate' should return Right(value) for a valid input", () {
      final input = EmailInput.dirty('email', 'somebody@somewhere.out.there');

      expect(input.result, Either.of(Email('somebody', 'somewhere.out.there')));
    });

    test("'validate' should return Left(ValidationError) for an invalid input",
        () {
      final input = EmailInput.dirty('email', 'invalid@@email.address');

      expect(
          input.result,
          Either.left(
              ValidationError('email', 'Value is not a valid email address.')));
    });

    test("should allow overriding 'validate'", () {
      final input = EmailInput.dirty('email', 'spammer@some.shady.host');

      expect(input.result,
          Either.left(ValidationError('email', 'Go away spammer!')));
    });

    test("should work with other mixins", () {
      final input = EmailInput.dirty('email', '');

      expect(input.result,
          Either.left(ValidationError('email', 'Please enter email.')));
    });
  });
}
