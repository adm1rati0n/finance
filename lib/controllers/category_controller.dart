import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:finance/controllers/history_controller.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/model_response.dart';
import 'package:finance/models/user.dart';
import 'package:finance/utils/app_utils.dart';

class CategoryController extends ResourceController {
  final ManagedContext managedContext;

  CategoryController(this.managedContext);

  @Operation.post()
  Future<Response> addCategory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Category category) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qCreateCategory = Query<Category>(managedContext)
        ..values.name = category.name;
      qCreateCategory.insert();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь ${user!.username} добавил категорию ${category.name}",
          user);

      return Response.ok(ModelResponse(message: "Категория добавлена"));
    } on QueryException catch (e) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось добавить данные", error: e.message));
    }
  }

  @Operation.put("categoryId")
  Future<Response> updateCategory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Category category,
      @Bind.path("categoryId") int categoryId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final oldCategory =
          await managedContext.fetchObjectWithID<Category>(categoryId);

      final qUpdateCategory = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(categoryId)
        ..values.name = category.name;
      qUpdateCategory.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь ${user!.username} изменил категорию ${oldCategory!.name}",
          user);

      return Response.ok(ModelResponse(message: "Операция изменена"));
    } on QueryException catch (e) {
      return Response.badRequest(
          body: ModelResponse(
              message: "Не удалось обновить данные", error: e.message));
    }
  }

  @Operation.delete("categoryId")
  Future<Response> deleteCategory(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("categoryId") int categoryId) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final category =
          await managedContext.fetchObjectWithID<Category>(categoryId);
      var query = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(categoryId);

      query.values.isDeleted = true;
      query.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь '${user!.username}' удалил категорию '${category!.name}'",
          user);
      return Response.ok(ModelResponse(message: "Категория удалена"));
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось удалить данные"));
    }
  }

  @Operation.get()
  Future<Response> getAllCategories(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query("search") String? search,
      @Bind.query("page") int page = 1,
      @Bind.query("limit") int limit = 10}) async {
    try {
      var query = Query<Category>(managedContext)
        ..where((x) => x.isDeleted).equalTo(false)
        ..where((x) => x.name).contains(search ?? "", caseSensitive: false)
        ..offset = (page - 1) * limit
        ..fetchLimit = limit;
      List<Category> categories = await query.fetch();

      return Response.ok(categories);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось загрузить данные"));
    }
  }

  @Operation.post("categoryId")
  Future<Response> restoreCategory(
    @Bind.path("categoryId") int categoryId,
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final category =
          await managedContext.fetchObjectWithID<Category>(categoryId);
      final id = AppUtils.getIdFromHeader(header);
      var query = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(categoryId);
      query.values.isDeleted = false;
      query.updateOne();

      final user = await managedContext.fetchObjectWithID<User>(id);
      HistoryController(managedContext).addRecord(
          "Пользователь '${user!.username}' восстановил категорию '${category!.name}'",
          user);
      return Response.ok(ModelResponse(message: "Категория восстановлена"));
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Категория с таким id не найдена"));
    }
  }

  @Operation.get("categoryId")
  Future<Response> getCategoryById(
      @Bind.path('categoryId') int categoryId) async {
    try {
      var query = Query<Category>(managedContext)
        ..where((x) => x.id).equalTo(categoryId);

      final category = await query.fetchOne();

      if (category == null) {
        return Response.badRequest(
            body: ModelResponse(message: "Категория с таким ID не найдена"));
      }
      return Response.ok(category);
    } catch (e) {
      return Response.badRequest(
          body: ModelResponse(message: "Не удалось получить данные"));
    }
  }
}
