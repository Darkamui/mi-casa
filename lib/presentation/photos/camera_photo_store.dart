import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'photo_store.dart';

/// The device camera, via `image_picker` (spec §2.4).
///
/// Every captured image is copied into the app's own support directory
/// before the path is handed back. That copy is not incidental:
///
/// - The plugin's temporary file can be reclaimed by the OS at any point,
///   and a comparison that vanishes mid-run is worse than none.
/// - It keeps the photo out of the shared gallery, where a backup client
///   would sync a picture of someone's kitchen to a server. §2.4 says
///   local-only and never uploaded, and the storage location is most of how
///   that promise is actually kept.
class CameraPhotoStore implements PhotoStore {
  CameraPhotoStore({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Only the platforms whose `image_picker` implementation can reach a
  /// camera. On desktop the plugin opens a file browser instead, which is a
  /// picture of nothing and an invitation to hand the app an arbitrary file.
  @override
  Future<bool> available() async =>
      Platform.isAndroid || Platform.isIOS;

  @override
  Future<String?> capture() async {
    if (!await available()) return null;

    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      // Plenty for a side-by-side on a phone, and small enough that a run's
      // pair costs a rounding error of storage.
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (shot == null) return null;

    final directory = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'photos'),
    );
    await directory.create(recursive: true);

    final destination = p.join(
      directory.path,
      '${DateTime.now().microsecondsSinceEpoch}${p.extension(shot.path)}',
    );
    await File(shot.path).copy(destination);
    return destination;
  }

  @override
  Future<void> discard(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
