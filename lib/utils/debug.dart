import 'dart:convert';

import 'package:flutter/foundation.dart';

void debugPrettyPrint(Object object) {
  // The object must have a toJson() method or be a List/Map
  final objectMap = (object as dynamic).toJson(); 
  
  // Use JsonEncoder with an indent for pretty printing
  const JsonEncoder encoder = JsonEncoder.withIndent('  '); 
  final String prettyJson = encoder.convert(objectMap);

  debugPrint('--- PRETTY JSON ---');
  debugPrint(prettyJson);
  debugPrint('-------------------');
}