import 'package:flutter/material.dart';
import 'package:shift/src/components/style/style.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 70,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          direction: DismissDirection.up,
          onDismissed: (direction) => overlayEntry.remove(),
          key: ValueKey(message),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 5),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              message,
              style: Styles.defaultStyleWhite13,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () => overlayEntry.remove());
}