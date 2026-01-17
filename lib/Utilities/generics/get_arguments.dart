import 'package:flutter/material.dart';

extension GetArguments on BuildContext {
  T? getArgument<T>(){
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is! T){
      return null;
    }
    return args;
  }
}