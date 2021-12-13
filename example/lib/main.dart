import 'package:flutter/material.dart';
import 'package:simple_async_builder/simple_async_builder.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleWidget());
  }
}

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final futureClickCount = Future<int>.delayed(const Duration(seconds: 2), () => 3);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: AsyncFutureBuilder<int>(
        future: futureClickCount,
        builder: (context, value) => Center(child: Text('Button was clicked $value times')),
      ),
    );
  }
}
