import 'package:conduit/conduit.dart';
import 'package:finance/models/user.dart';

class History extends ManagedObject<_History> implements _History {}

@Table(name: 'history')
class _History {
  @primaryKey
  int? id;
  @Column(unique: false)
  String? title;
  @Relate(#histories)
  User? user;
}
