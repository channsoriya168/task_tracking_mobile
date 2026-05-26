import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService {
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  Future<bool> isUpdateAvailable() async {
    try {
      final status = await _updater.checkForUpdate();
      return status == UpdateStatus.outdated;
    } catch (_) {
      return false;
    }
  }

  Future<void> downloadUpdate() async {
    await _updater.update();
  }

  Future<Patch?> currentPatch() async {
    return _updater.readCurrentPatch();
  }

  /// Checks for an available patch and downloads it if found.
  /// Returns true if a patch was downloaded successfully.
  Future<bool> checkAndUpdate() async {
    try {
      if (await isUpdateAvailable()) {
        await downloadUpdate();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
