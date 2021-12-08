# simple_async_builder

[![pub package](https://img.shields.io/pub/v/simple_async_builder.svg)](https://pub.dartlang.org/packages/simple_async_builder)
[![Dart](https://github.com/bartektartanus/simple_async_builder/actions/workflows/flutter.yml/badge.svg)](https://github.com/bartektartanus/simple_async_builder/actions/workflows/flutter.yml)

Simple `Future` and `Stream` builder for Flutter.
This package provides `AsyncFutureBuilder` and `AsyncStreamBuilder` - more developer-friendly 
versions of `FutureBuilder` and `StreamBuilder`.

This package was inspired by `async_builder`.

## Usage

This simple code:
```dart
AsyncFutureBuilder<int>(
  future: Future<int>.delayed(const Duration(seconds: 2), () => 3),
  builder: (context, value) => Text("Button was clicked $value times"),
)
```
let's you achieve this:

![example-widget](doc/example-widget.gif)

You can find a complete example in `example/lib/main.dart`