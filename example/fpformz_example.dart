import 'package:fpformz/fpformz.dart';

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
  final form = RegistrationForm(
      name: NameInput.dirty('name', 'Anna'),
      email: EmailInput.dirty('email', 'someone@some.where'));

  print(form.isValid);
}
