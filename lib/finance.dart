import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:finance/controllers/app_token_controller.dart';
import 'package:finance/controllers/app_user_controller.dart';
import 'package:finance/controllers/category_controller.dart';
import 'package:finance/controllers/history_controller.dart';
import 'package:finance/controllers/transaction_controller.dart';
import 'package:finance/models/user.dart';
import 'package:finance/models/transaction.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/history.dart';

import 'controllers/app_auth_controller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext))
    ..route('transaction/[:transactionId]')
        .link(AppTokenController.new)!
        .link(() => TransactionController(managedContext))
    ..route('category/[:categoryId]')
        .link(AppTokenController.new)!
        .link(() => CategoryController(managedContext))
    ..route('history')
        .link(AppTokenController.new)!
        .link(() => HistoryController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? '12345678';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'finance';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
