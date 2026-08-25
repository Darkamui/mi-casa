import 'dart:async';

/// Where before/after photos come from and go (spec §2.4).
///
/// The contract is deliberately narrow, and the narrowness is the point:
/// **no implementation of this may upload, share, back up, or transmit an
/// image anywhere.** §2.4 says local-only, never uploaded, never shared by
/// default, and a photograph of the inside of someone's home is not a thing
/// to be casual about. There is no `upload`, no `url`, and no `share` here,
/// and none should be added.
///
/// [capture] returns a path the app owns and may delete; a null return means
/// the user backed out, which is not an error and must not be reported as one.
abstract class PhotoStore {
  /// Whether this device can take a picture at all.
  Future<bool> available();

  /// Take one. Null if the user changed their mind.
  Future<String?> capture();

  /// Delete a file this store handed out. Deleting something already gone is
  /// not an error - the caller should never have to check first.
  Future<void> discard(String path);
}

/// The default: a device with no camera we can reach.
///
/// The run plays identically without photos, so the honest response to a
/// missing camera is to say nothing about it.
class UnavailablePhotoStore implements PhotoStore {
  const UnavailablePhotoStore();

  @override
  Future<bool> available() async => false;

  @override
  Future<String?> capture() async => null;

  @override
  Future<void> discard(String path) async {}
}
