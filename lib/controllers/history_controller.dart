import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:finance/models/history.dart';
import 'package:finance/utils/app_utils.dart';
import 'package:finance/models/model_response.dart';
import 'package:finance/models/user.dart';

class HistoryController extends ResourceController {
  final ManagedContext managedContext;

  HistoryController(this.managedContext);

  void addRecord(String title, User user) async {
    final qAddHistory = Query<History>(managedContext)
      ..values.title = title
      ..values.user = user;
    qAddHistory.insert();
  }

  @Operation.get()
  Future<Response> getCurrentUserHistory(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final query = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..join(set: (x) => x.histories);
      final user = await query.fetchOne();

      return Response.ok(user!.histories);
    } catch (e) {
      return Response.serverError(
          body:
              ModelResponse(message: "Не удалось загрузить историю действий"));
    }
  }
}
