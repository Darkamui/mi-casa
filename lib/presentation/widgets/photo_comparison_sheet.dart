import 'dart:io';

import 'package:flutter/material.dart';

import 'before_after_slider.dart';

/// The end of a run, when a "before" was taken (spec §2.4).
///
/// Two states, and only two: an invitation to take the matching "after", and
/// then the slider itself. Both are dismissible with a tap, because the
/// photograph is an aside to the run and never a gate on finishing it.
///
/// The delete affordance is not buried. These are pictures of the inside of
/// someone's home, and §2.4's "local-only, never uploaded, never shared by
/// default" is only worth the promise if throwing them away is as easy as
/// taking them.
class PhotoComparisonSheet extends StatelessWidget {
  const PhotoComparisonSheet({
    super.key,
    required this.beforePath,
    required this.onDismiss,
    required this.onDiscard,
    this.afterPath,
    this.onTakeAfter,
  });

  final String beforePath;

  /// Null until the "after" is taken - the invitation state.
  final String? afterPath;

  final VoidCallback onDismiss;
  final VoidCallback onDiscard;
  final VoidCallback? onTakeAfter;

  @override
  Widget build(BuildContext context) {
    final after = afterPath;

    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.72),
          child: Center(
            child: GestureDetector(
              // The panel itself is not a dismiss target: dragging the
              // divider must not close the thing being dragged.
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (after == null)
                      _Invitation(onTakeAfter: onTakeAfter)
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420,
                          maxHeight: 340,
                        ),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: BeforeAfterSlider(
                            before: FileImage(File(beforePath)),
                            after: FileImage(File(after)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: onDiscard,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9A9AA6),
                          ),
                          child: const Text('DELETE'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onDismiss,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CLOSE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Invitation extends StatelessWidget {
  const _Invitation({this.onTakeAfter});

  final VoidCallback? onTakeAfter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'SEE THE DIFFERENCE',
          style: TextStyle(
            color: Color(0xFFA9C7A0),
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onTakeAfter,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('TAKE THE AFTER'),
        ),
      ],
    );
  }
}
