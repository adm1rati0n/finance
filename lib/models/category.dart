import 'package:conduit/conduit.dart';
import 'package:finance/models/transaction.dart';

class Category extends ManagedObject<_Category> implements _Category {}

@Table(name: "category")
class _Category {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;
  @Column(defaultValue: 'false')
  bool? isDeleted;

  ManagedSet<Transaction>? transactions;
}
