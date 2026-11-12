import 'dart:convert';
import 'dart:io';

const _encoder = JsonEncoder.withIndent('  ');
const _ansiEsc = '\x1B[';
const _ansiDefault = '${_ansiEsc}0m';

mixin LogMixin {
  void printRequest(Object? value, [String prefix = ""]) => _print(value, 208, prefix);

  void printError(Object? value, [String prefix = ""]) => _print(value, 196, prefix);

  void printResponse(Object? value, [String prefix = ""]) => _print(value, 77, prefix);

  void _print(Object? object, int foregroundColor, String prefix) {
    String content;
    if (object is Map || object is List) {
      content = _encoder.convert(object);
    } else {
      content = object.toString();
    }
    if (prefix.isNotEmpty) content = "$prefix: $content";
    content.split("\n").forEach((element) {
      try {
        if (stdout.supportsAnsiEscapes) {
          print("${_ansiEsc}38;5;${foregroundColor}m$element$_ansiDefault");
        } else {
          throw UnsupportedError("Ansi escapes not supported!");
        }
      } catch (_) {
        print(element);
      }
    });
  }
}
