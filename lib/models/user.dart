import 'package:conduit/conduit.dart';
import 'package:finance/models/history.dart';
import 'package:finance/models/transaction.dart';

class User extends ManagedObject<_User> implements _User {}

// @Table(name: 'user')
class _User {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? username;
  @Column(unique: true, indexed: true)
  String? email;
  @Serialize(input: true, output: false)
  String? password;
  @Column(nullable: true)
  String? accessToken;
  @Column(nullable: true)
  String? refreshToken;
  @Column(omitByDefault: true)
  String? salt;
  @Column(omitByDefault: true)
  String? hashPassword;

  ManagedSet<Transaction>? transactions;
  ManagedSet<History>? histories;
}
