import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:finance/utils/app_const.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils{
  const AppUtils._();

  static int getIdFromToken(String token){
    try{
      final key = AppConst.secretKey;
      final jwtClaim = verifyJwtHS256Signature(token, key);
      return int.parse(jwtClaim['id'].toString());
    } catch(e){
      rethrow;
    }
  }

  static int getIdFromHeader(String header){
    try{
      final token = const AuthorizationBearerParser().parse(header);
      final id = getIdFromToken(token ?? "");
      return id;
    } catch(e){
      rethrow;
    }
  }
}