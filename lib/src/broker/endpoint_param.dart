import 'package:analyzer/dart/element/element.dart';

import '../utils/field_type.dart';

class EndpointParam {
  final String name;
  final TransferFieldType type;

  EndpointParam(this.name, this.type);

  EndpointParam.fromParam(ParameterElement param)
      : name = param.name,
        type = TransferFieldType.fromDartType(param.type);

  String get paramStatement => '${type.typeNameNullability} $name';

  String encodingStatement(String accessor) =>
      type.buildEncodingStatement(accessor);

  String decodingStatement(String accessor) =>
      type.buildDecodingStatement(accessor, "'$name'");
}
