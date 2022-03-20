extension StringExtension on String {
  String capitalise() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
}
