import 'package:flutter/material.dart';

/// Chrome for a detail page that has nothing to show yet.
///
/// Keeping the app bar in *every* state matters on iOS: previously the
/// loading state rendered a bare [Scaffold], so the screen appeared
/// title-less and then popped a nav bar into existence once the data landed.
class AsyncPagePlaceholder extends StatelessWidget {
  const AsyncPagePlaceholder({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: body),
    );
  }
}

/// Loads [future] and hands the result to [builder], rendering consistent
/// loading / error / not-found chrome in the meantime.
///
/// Collapses the loading-error-missing-loaded ladder that the detail screens
/// each repeated by hand.
class AsyncPage<T> extends StatelessWidget {
  const AsyncPage({
    super.key,
    required this.future,
    required this.fallbackTitle,
    required this.builder,
    required this.errorMessage,
    required this.missingMessage,
    this.isMissing,
  });

  final Future<T> future;

  /// Title shown while loading and on the error / not-found states, before
  /// the real title is known.
  final String fallbackTitle;

  final Widget Function(BuildContext context, T data) builder;
  final String Function(Object error) errorMessage;
  final String missingMessage;

  /// Some repositories signal "not found" with a sentinel rather than null
  /// (e.g. `id == -1`); this hook covers both.
  final bool Function(T data)? isMissing;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return AsyncPagePlaceholder(
            title: fallbackTitle,
            body: const CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          return AsyncPagePlaceholder(
            title: fallbackTitle,
            body: Text(errorMessage(snapshot.error!)),
          );
        }
        final data = snapshot.data;
        if (data == null || (isMissing?.call(data) ?? false)) {
          return AsyncPagePlaceholder(
            title: fallbackTitle,
            body: Text(missingMessage),
          );
        }
        return builder(context, data);
      },
    );
  }
}
