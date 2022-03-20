import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'input.dart';
import 'validate.dart';

@immutable
abstract class Form
    implements Validatable<Map<String, dynamic>, ValidationError> {
  const Form();

  List<FormInput<dynamic, dynamic, ValidationError>> get inputs;

  @override
  bool get isPristine => inputs.every((i) => i.isPristine);

  @override
  // TODO: Should be simplified once fpdart supports Traverse.
  Either<ValidationError, Map<String, dynamic>> get result => inputs.foldRight(
      Either.of({}),
      (i, acc) => acc.bind((m) => i.result.match(
          (l) => Either.left(l), (r) => Either.of(m..addAll({i.name: r})))));
}

extension FormExtension on Form {
  List<ValidationError> get errors => inputs
      .foldLeft([], (acc, i) => i.result.match((l) => acc..add(l), (r) => acc));
}
