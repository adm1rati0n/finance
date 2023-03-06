import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/history.dart';
import 'package:finance/controllers/history_controller.dart';
import 'package:finance/models/model_response.dart';
import 'package:finance/models/transaction.dart';
import 'package:finance/models/user.dart';
import 'package:finance/utils/app_utils.dart';

class TransactionController extends ResourceController {
  final ManagedContext managedContext;

  TransactionController(this.managedContext);

  @Operation.post()
  Future<Response> addTransaction(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Transaction transaction) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();

      final qCreateTransaction = Query<Transaction>(managedContext)
        ..values.number = transaction.number
        ..values.name = transaction.name
        ..values.description = transaction.description
        ..values.date = DateTime.now()
        ..values.total = transaction.total
        ..values.category!.id = transaction.category!.id
        ..values.user!.id = id;
      qCreateTransaction.insert();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь ${user!.username} добавил операцию ${transaction.name}",
          user);

      return Response.ok(ModelResponse(message: "Операция добавлена"));
    } on QueryException catch (e) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось добавить данные", error: e.message));
    }
  }

  @Operation.put('transactionId')
  Future<Response> updateTransaction(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Transaction transaction,
      @Bind.path('transactionId') int transactionId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qFindUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..returningProperties((x) => [x.salt, x.hashPassword]);

      final fUser = await qFindUser.fetchOne();

      final oldTransaction =
          await managedContext.fetchObjectWithID<Transaction>(transactionId);

      final qUpdateTransaction = Query<Transaction>(managedContext)
        ..where((x) => x.id).equalTo(transactionId)
        ..values.number = transaction.number
        ..values.name = transaction.name
        ..values.description = transaction.description
        ..values.date = DateTime.now()
        ..values.total = transaction.total
        ..values.category!.id = transaction.category!.id
        ..values.user!.id = fUser!.id;

      qUpdateTransaction.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь ${user!.username} изменил операцию ${oldTransaction!.name}",
          user);

      return Response.ok(ModelResponse(message: "Операция изменена"));
    } on QueryException catch (e) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось обновить данные", error: e.message));
    }
  }

  @Operation.delete("transactionId")
  Future<Response> deleteTransaction(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("transactionId") int transactionId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final transaction =
          await managedContext.fetchObjectWithID<Transaction>(transactionId);
      var query = Query<Transaction>(managedContext)
        ..where((x) => x.id).equalTo(transactionId);

      query.values.isDeleted = true;
      query.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь '${user!.username}' удалил операцию '${transaction!.name}'",
          user);
      return Response.ok(ModelResponse(message: "Операция удалена"));
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось удалить данные"));
    }
  }

  @Operation.get()
  Future<Response> getAllTransactions(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query("search") String? search,
      @Bind.query("filter") String? filter,
      @Bind.query("page") int page = 1,
      @Bind.query("limit") int limit = 10}) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final query = Query<Transaction>(managedContext)
        ..join(object: (x) => x.user)
        ..join(object: (x) => x.category)
        ..where((x) => x.user?.id).equalTo(id)
        ..where((x) => x.isDeleted).equalTo(false)
        ..where((x) => x.name).contains(search ?? "", caseSensitive: false)
        ..offset = (page - 1) * limit
        ..fetchLimit = limit;
      if (filter != "") {
        query.where((x) => x.category!.name).equalTo(filter);
      }
      List<Transaction> transactions = await query.fetch();

      for (var transaction in transactions) {
        transaction.user!
            .removePropertiesFromBackingMap(['accessToken', 'refreshToken']);
      }
      return Response.ok(transactions);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось загрузить данные"));
    }
  }

  @Operation.get("transactionId")
  Future<Response> getTransactionById(
      @Bind.path('transactionId') int transactionId) async {
    try {
      var query = Query<Transaction>(managedContext)
        ..join(object: (x) => x.user)
        ..join(object: (x) => x.category)
        ..where((x) => x.id).equalTo(transactionId);

      final transaction = await query.fetchOne();

      if (transaction == null) {
        return Response.badRequest(
            body: ModelResponse(message: "Операция с таким ID не найдена"));
      }

      transaction.user!
          .removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      return Response.ok(transaction);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить данные"));
    }
  }
}
