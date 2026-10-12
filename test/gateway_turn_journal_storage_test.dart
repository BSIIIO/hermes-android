import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/gateway_turn_journal.dart';

void main() {
  test('turn journal keeps its namespace but drops migrateWithBackup', () {
    // Same hazard as the connection credential store: the *WithBackup
    // migration paths in flutter_secure_storage 10.3.1 ignore
    // storageNamespace when opening the wrapped-key prefs.
    //
    // AndroidOptions keeps those flags private, so assert on the map that is
    // actually handed to the platform channel — that is the real contract.
    final options =
        FlutterSecureGatewayTurnJournalStore.androidOptionsForTest.toMap();
    expect(options['storageNamespace'], 'hermes_android_turn_recovery');
    expect(options['resetOnError'], 'false');
    expect(options['migrateWithBackup'], 'false');
    expect(options['migrateOnAlgorithmChange'], 'true');
  });
}
