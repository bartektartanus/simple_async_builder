import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class AsyncStreamBuilder<T> extends StatefulWidget {
  /// The builder that should be called when no data is available.
  final WidgetBuilder waiting;

  /// The default value builder.
  final ValueBuilderFn<T> builder;

  /// The builder that should be called when an error was thrown by the future
  /// or stream.
  final ErrorBuilderFn error;

  /// The builder that should be called when the stream is closed.
  final ValueBuilderFn<T>? closed;

  /// If provided, this is the stream the widget listens to.
  final Stream<T> stream;

  /// The initial value used before one is available.
  final T? initial;

  /// Whether or not the current value should be retained when the [stream] or
  /// [future] instances change.
  final bool retain;

  /// Whether or not to suppress printing errors to the console.
  final bool silent;

  /// Whether or not to pause the stream subscription.
  final bool pause;

  /// If provided, overrides the function that prints errors to the console.
  final ErrorReporterFn reportError;

  /// Creates a widget that builds depending on the state of a [Future] or [Stream].
  AsyncStreamBuilder({
    Key? key,
    WidgetBuilder? waiting,
    required this.builder,
    ErrorBuilderFn? error,
    this.closed,
    required this.stream,
    this.initial,
    this.retain = false,
    this.pause = false,
    bool? silent,
    ErrorReporterFn? reportError,
  })  : silent = silent ?? error != null,
        waiting = waiting ??
            ((c) => const Center(child: CircularProgressIndicator())),
        error = error ?? errorWidget(),
        reportError = reportError ?? FlutterError.reportError,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _AsyncStreamBuilderState<T>();
}

class _AsyncStreamBuilderState<T> extends State<AsyncStreamBuilder<T>> {
  Either<Object, T>? _errorOrValue;
  StackTrace? _lastStackTrace;
  bool _isClosed = false;
  StreamSubscription<T>? _subscription;

  void _cancel() {
    if (!widget.retain) {
      _errorOrValue = null;
      _lastStackTrace = null;
    }
    _isClosed = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    _errorOrValue = Left(error);
    _lastStackTrace = stackTrace;
    if (mounted) {
      setState(() {});
    }
    if (!widget.silent) {
      widget.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace ?? StackTrace.empty,
        context: ErrorDescription('While updating AsyncBuilder'),
      ));
    }
  }

  void _updatePause() {
    if (_subscription != null) {
      if (widget.pause && !_subscription!.isPaused) {
        _subscription!.pause();
      } else if (!widget.pause && _subscription!.isPaused) {
        _subscription!.resume();
      }
    }
  }

  void _initStream() {
    _cancel();
    final stream = widget.stream;
    var skipFirst = false;
    _subscription = stream.listen(
      (T event) {
        if (skipFirst) {
          skipFirst = false;
          return;
        }
        setState(() {
          _errorOrValue = Right(event);
        });
      },
      onDone: () {
        _isClosed = true;
        if (widget.closed != null) {
          setState(() {});
        }
      },
      onError: _handleError,
    );
  }

  @override
  void initState() {
    super.initState();
    _initStream();
    _updatePause();
  }

  @override
  void didUpdateWidget(AsyncStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      _initStream();
    }
    _updatePause();
  }

  @override
  Widget build(BuildContext context) {
    final errorOrValue = _errorOrValue;
    if (errorOrValue == null) {
      final initial = widget.initial;
      if (initial != null) {
        return widget.builder(context, initial);
      } else {
        return widget.waiting(context);
      }
    } else if (errorOrValue.isLeft) {
      return widget.error(context, errorOrValue.left, _lastStackTrace);
    } else if (_isClosed && widget.closed != null) {
      return widget.closed!(context, errorOrValue.right);
    } else {
      return widget.builder(context, errorOrValue.right);
    }
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }
}
