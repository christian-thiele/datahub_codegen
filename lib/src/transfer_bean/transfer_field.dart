import '../utils/field_type.dart';

import '../utils/utils.dart';

class TransferField {
  final String name;
  final String key;
  final TransferFieldType type;
  final bool named;

  TransferField(this.name, this.key, this.type, this.named);

  String buildEncodingStatement(String transferObjectAccessor) {
    final fieldAccessor = '$transferObjectAccessor.$name';
    return type.buildEncodingStatement(fieldAccessor);
  }

  String buildDecodingStatement(String dataMapAccessor) {
    final keyAccessor = "$dataMapAccessor['$key']";
    return type.buildDecodingStatement(keyAccessor);
  }
}
