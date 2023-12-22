import 'package:fpformz/fpformz.dart';

class NameInput extends StringFormInput<String, ValidationError>
    with NonEmptyString {
  const NameInput.pristine(super.name, super.value) : super.pristine();

  const NameInput.dirty(super.name, super.value) : super.dirty();

  @override
  String convert(String value) => value;
}

class EmailInput extends StringFormInput<String, ValidationError>
    with EmailString {
  const EmailInput.pristine(super.name, super.value) : super.pristine();

  const EmailInput.dirty(super.name, super.value) : super.dirty();

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
  final form = RegistrationForm(
      name: NameInput.dirty('name', 'Anna'),
      email: EmailInput.dirty('email', 'someone@some.where'));

  print(form.isValid);
}
