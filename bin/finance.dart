import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:finance/finance.dart';

void main() async {
  final port = int.parse(Platform.environment["Port"] ?? '8888');
  final service = Application<AppService>()
    ..options.port = port
    ..options.configurationFilePath = 'config.yaml';

  await service.start(numberOfInstances: 3, consoleLogging: true);
}
