import 'package:fpdart/fpdart.dart';
import 'package:fpformz/fpformz.dart';
import 'package:test/test.dart';

class NameInput extends StringFormInput<String, ValidationError>
    with NonEmptyString {
  const NameInput.pristine(name, value) : super.pristine(name, value);

  const NameInput.dirty(name, value) : super.dirty(name, value);

  @override
  String convert(String value) => value;
}

class EmailInput extends StringFormInput<String, ValidationError>
    with EmailString {
  const EmailInput.pristine(name, value) : super.pristine(name, value);

  const EmailInput.dirty(name, value) : super.dirty(name, value);

  @override
  String convert(String value) => value;
}

class RegistrationForm with Form {
  final NameInput name;

  final EmailInput email;

  const RegistrationForm(
      {this.name = const NameInput.pristine('name', ''),
      this.email = const EmailInput.pristine('email', '')});

  @override
  get inputs => [name, email];
}

void main() {
  group('Form', () {
    test("'isPristine' should be true when it contains only unmodified inputs",
        () {
      final form = RegistrationForm();

      expect(form.isPristine, true);
    });

    test("'isPristine' should be false when any of its inputs is modified", () {
      final form = RegistrationForm(name: NameInput.dirty('name', 'Anna'));

      expect(form.isPristine, false);
    });

    test("'isValid' should be true when all inputs are valid", () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', 'Anna'),
          email: EmailInput.dirty('email', 'someone@some.where'));

      expect(form.isValid, true);
    });

    test("'isValid' should be false when any of the inputs is invalid", () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', 'Anna'),
          email: EmailInput.dirty('email', 'someone!some.where'));

      expect(form.isValid, false);
    });

    test(
        "'result' should return all validated values as a map when all inputs are valid",
        () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', 'Anna'),
          email: EmailInput.dirty('email', 'someone@some.where'));

      final values = form.resultOrNull!;

      expect(values.length, 2);

      expect(values['name'], 'Anna');
      expect(values['email'], 'someone@some.where');
    });

    test(
        "'result' should return the validation error of the first invalid input when there's any",
        () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', 'Anna'),
          email: EmailInput.dirty('email', 'someone!some.where'));

      expect(
          form.result,
          Either.left(
              ValidationError('email', '"someone!some.where" is not a valid email address.')));
    });

    test("'errors' should return all validation errors of contained inputs",
        () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', ''),
          email: EmailInput.dirty('email', 'someone!some.where'));

      expect(form.errors, [
        ValidationError('name', 'Please enter name.'),
        ValidationError('email', '"someone!some.where" is not a valid email address.')
      ]);
    });

    test("'errors' should return an empty list when all inputs are valid", () {
      final form = RegistrationForm(
          name: NameInput.dirty('name', 'Anna'),
          email: EmailInput.dirty('email', 'someone@some.where'));

      expect(form.errors, []);
    });
  });
}
