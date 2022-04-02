[![License: MIT][license_badge]][license_link]
[![ci][ci_badge]][ci_link]
[![pub package][pub_badge]][pub_link]

# FPFormz

Functional input validation library based on [Fpdart](https://github.com/SandroMaglione/fpdart),
which is inspired by [Formz](https://github.com/VeryGoodOpenSource/formz).

## Features

For the most part, FPFormz is similar to the original Formz library, with a few notable differences:

* FPFormz allows specifying different types for input and validated values, which can be convenient
  when using non-string type values (e.g. `int`, `enum`, value class, etc.).

* It exposes validated values and errors as functional constructs such as `Either` or `Option`,
  making it easier to manipulate them declaratively.

* It also provides a way to write validation logic as mixins, which you can combine to handle more
  complex use cases.

## Installation

You can install PFFormz by adding the following entry in your `pubsec.yaml`:

```yaml
# pubspec.yaml
dependencies:
  fpformz: ^0.1.3
```

## Getting Started

### FormInput And Its Derivatives

To define a validatable input, you need to write a class that extends `FormInput<V, I, E>` whose
generic parameters correspond to the type of resulting value, input value, and potential errors,
respectively:

```dart
class AgeInput extends FormInput<int, String, ValidationError> {
  const AgeInput.pristine(name, value) : super.pristine(name, value);

  const AgeInput.dirty(name, value) : super.dirty(name, value);

  Either<ValidationError, int> validate(String value) =>
      Either.tryCatch(() => int.parse(value),
              (e, s) => ValidationError(name, '$name should be a number.'));
}
```

After declaring your input, you can use either `pristine` or `dirty` constructor to create an
instance:

```dart
void example() {
  // To create an unmodified ('pristine') input instance:
  final age = AgeInput.pristine('age', '');

  // Or you can create a modified ('dirty') input instance as below:
  final editedAge = AgeInput.dirty('age', '23');

  print(age.isPristine); // returns 'true'
  print(editedAge.isPristine); // returns 'false'
}
```

You can access validation information either as a functional construct, or as a nullable:

```dart
void example() {
  print(editedAge.isValid); // returns true
  print(editedAge.result); // returns Right(23)
  print(editedAge.resultOrNull); // returns 23
  print(editedAge.error); // returns None
  print(editedAge.errorOrNull); // returns null

  print(age.isValid); // returns false
  print(age.result); // returns Left(ValidationError)
  print(age.resultOrNull); // returns null
  print(age.error); // returns Some(ValidationError)
  print(age.errorOrNull); // returns ValidationError
}
```

And because most input components treat the user input as a `String` instance, you can simplify the
type signature by extending from `StringFormInput`:

```dart
class NameInput extends StringFormInput<String, ValidationError> {
  const NameInput.pristine(name, value) : super.pristine(name, value);

  const NameInput.dirty(name, value) : super.dirty(name, value);

  @override
  String convert(String value) => value;

  @override
  Either<ValidationError, String> validate(String value) =>
      value.isEmpty
          ? Either.left(ValidationError(name, 'The name cannot be empty.'))
          : super.validate(value);
}
```

### Form

Like with Formz, you can create a form class to host multiple input fields and validate them
together:

```dart
class RegistrationForm extends Form {

  final NameInput name;
  final EmailInput email;

  const RegistrationForm({
    this.name = const NameInput.pristine('name', ''),
    this.email = const EmailInput.pristine('email', '')
  });

  @override
  get inputs => [name, email];
}
```

Then you can validate it using a similar API like that of `FormInput`:

```dart
void example() {
  final form = RegistrationForm();

  print(form.isPristine); // returns true
  print(form.isValid); // returns false

  print(form.result); // it 'short circuits' at the first error encountered
  print(form.errors); // but you can get all errors this way. 
}
```

`Form.result` returns a map of all validated input values which you can use to invoke a service
method:

```dart
void example() {
  final form = RegistrationForm();

  final params = form.resultOrNull;

  service.register(params[form.email.name], params[form.password.name]);

  // Or even like this, provided that the input names match those of the parameters:  
  Function.apply(service.register, [], params);
}
```

### Mixins

You can also write reusable validation logic as a mixin:

```dart
@immutable
mixin NonEmptyString<V> on FormInput<V, String, ValidationError> {
  ValidationError get whenEmpty => ValidationError(name, 'Please enter $name.');

  @override
  Either<ValidationError, V> validate(String value) =>
      value.isEmpty ? Either.left(whenEmpty) : super.validate(value);
}
```

And build a concrete input field by adding them to either `BaseFormInput` or `StringFormInput` as
shown below:

```dart
class EmailInput extends StringFormInput<Email, ValidationError>
    with EmailString, NonEmptyString {
  const EmailInput.pristine(name, value) : super.pristine(name, value);

  const EmailInput.dirty(name, value) : super.dirty(name, value);

  @override
  Email convert(String value) => Email.parse(value);
}
```

It's recommended to split each validation logic into a separate mixin rather than putting all into
an input class to maximise code reuse and achieve separation of concerns (i.e. the 'S'
in [SOLID](https://en.wikipedia.org/wiki/SOLID) principles).

FPFormz also ships with a small collection of ready-to-use mixins like `NonEmptyString`
, `StringShorterThan`, which might be expanded in future versions.

## Additional Information

You can find more code examples in
our [test cases](https://github.com/mysticfall/fpformz/tree/main/test).

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg

[license_link]: https://opensource.org/licenses/MIT

[ci_link]: https://github.com/mysticfall/fpformz/actions

[ci_badge]: https://github.com/mysticfall/fpformz/actions/workflows/main.yml/badge.svg

[pub_badge]: https://img.shields.io/pub/v/fpformz.svg

[pub_link]: https://pub.dartlang.org/packages/fpformz
