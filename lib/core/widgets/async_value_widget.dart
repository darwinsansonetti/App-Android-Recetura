import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Wrapper unificado para AsyncValue de Riverpod
/// Uso: `AsyncValueWidget<List<Producto>>(value: asyncValue, data: ...)`
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? st)? error;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading?.call() ?? const LoadingView(),
      error: (e, st) => error?.call(e, st) ?? ErrorView(message: e.toString()),
    );
  }
}
