import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

import '../utils/field_type.dart';

class EndpointParam {
  final String name;
  final TransferFieldType type;
  final bool nullable;

  EndpointParam(this.name, this.type, this.nullable);

  EndpointParam.fromParam(ParameterElement param)
      : name = param.name,
        type = TransferFieldType.fromDartType(param.type),
        nullable = param.type.nullabilitySuffix != NullabilitySuffix.none;

  String get paramStatement => '${type.typeName}$nullabilitySuffix $name';

  String encodingStatement(String accessor) =>
      type.buildEncodingStatement(accessor, nullable);

  String decodingStatement(String accessor) =>
      type.buildDecodingStatement(accessor, nullable);

  String get nullabilitySuffix => nullable ? '?' : '';
}