import 'package:flutter/widgets.dart';

class Validators {
  static FormFieldValidator<String>? required(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }
}