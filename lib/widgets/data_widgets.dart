import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/app_data.dart';
import 'peer_ui.dart';

String dataError(Object error) {
  if (error is FirebaseException) {
    return error.message ?? 'Could not save changes. Please try again.';
  }
  return error.toString().replaceFirst('Bad state: ', '');
}

Future<bool> perform(BuildContext context, Future<void> Function() action,
    {String? success}) async {
  try {
    await action().timeout(const Duration(seconds: 30));
    if (success != null && context.mounted) peerNotice(context, success);
    return true;
  } catch (error) {
    if (context.mounted) peerNotice(context, dataError(error));
    return false;
  }
}

class DataView extends StatelessWidget {
  final Widget Function(BuildContext, AppData) builder;
  const DataView({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: AppData.instance,
      builder: (context, _) {
        final data = AppData.instance;
        if (data.loading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (data.error != null) {
          return PeerPage(title: 'Connection issue', children: [
            PeerCard(children: [
              Text(data.error!),
              PeerButton('Retry', onPressed: () => data.initialize())
            ])
          ]);
        }
        return builder(context, data);
      });
}

class AsyncPeerButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Future<void> Function()? action;
  final bool secondary, orange;
  const AsyncPeerButton(this.label,
      {super.key,
      required this.action,
      this.icon,
      this.secondary = false,
      this.orange = false});
  @override
  State<AsyncPeerButton> createState() => _AsyncPeerButtonState();
}

class _AsyncPeerButtonState extends State<AsyncPeerButton> {
  bool busy = false;
  @override
  Widget build(BuildContext context) =>
      PeerButton(busy ? 'Please wait…' : widget.label,
          icon: widget.icon,
          secondary: widget.secondary,
          orange: widget.orange,
          onPressed: busy || widget.action == null
              ? null
              : () async {
                  setState(() => busy = true);
                  await perform(context, widget.action!);
                  if (mounted) setState(() => busy = false);
                });
}
