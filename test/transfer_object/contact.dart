import 'package:datahub/datahub.dart';

import 'json_fields.dart';

part 'contact.g.dart';

@TransferObject()
class Contact extends _TransferObject {
  @TransferId()
  final String id;
  final String name;
  final String number;
  final String address;
  final List<int> intList;
  final List<JsonFields> jsonFieldList;

  Contact(this.id, this.name, this.number, this.address, this.intList,
      this.jsonFieldList);
}
