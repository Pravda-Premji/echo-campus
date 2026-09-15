import 'package:flutter/material.dart';

/// Optional, student-assigned sense of how disruptive an observation is.
/// Purely informational — it does not feed into the reliability/decay math.
enum EchoSeverity {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case EchoSeverity.low:
        return 'Low';
      case EchoSeverity.medium:
        return 'Medium';
      case EchoSeverity.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case EchoSeverity.low:
        return const Color(0xFF047857);
      case EchoSeverity.medium:
        return const Color(0xFFB45309);
      case EchoSeverity.high:
        return const Color(0xFFBE123C);
    }
  }
}
