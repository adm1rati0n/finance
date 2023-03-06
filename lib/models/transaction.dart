import 'package:conduit/conduit.dart';
import 'package:finance/models/category.dart';
import 'package:finance/models/user.dart';

class Transaction extends ManagedObject<_Transaction> implements _Transaction {}

@Table(name: "transaction")
class _Transaction {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? number;
  @Column(unique: false, indexed: true)
  String? name;
  @Column(unique: false, indexed: true)
  String? description;
  @Column(unique: false, indexed: true)
  DateTime? date;
  @Column(unique: false, indexed: true)
  double? total;
  @Relate(#transactions)
  Category? category;
  @Relate(#transactions)
  User? user;
  @Column(defaultValue: 'false')
  bool? isDeleted;
}
