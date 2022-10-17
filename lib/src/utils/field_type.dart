import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'utils.dart';

abstract class TransferFieldType {
  final bool nullable;

  String get typeName;

  String get typeNameNullability => typeName + (nullable ? '?' : '');

  const TransferFieldType(this.nullable);

  String buildEncodingStatement(String valueAccessor) {
    return 'encodeTyped<$typeNameNullability>($valueAccessor)';
  }

  String buildDecodingStatement(String valueAccessor) {
    return 'decodeTyped<$typeNameNullability>($valueAccessor)';
  }

  factory TransferFieldType.fromDartType(DartType type) {
    final nullable = type.nullabilitySuffix != NullabilitySuffix.none;
    if (type.isDynamic) {
      return DynamicFieldType();
    } else if (type.isDartCoreString) {
      return StringFieldType(nullable);
    } else if (type.isDartCoreInt) {
      return IntFieldType(nullable);
    } else if (type.isDartCoreDouble) {
      return DoubleFieldType(nullable);
    } else if (type.isDartCoreBool) {
      return BoolFieldType(nullable);
    } else if (type.isDartCoreDateTime) {
      return DateTimeFieldType(nullable);
    } else if (type.isDartCoreDuration) {
      return DurationFieldType(nullable);
    } else if (type.isUint8List) {
      return ByteFieldType(nullable);
    } else if (type.isDartCoreList) {
      final arg = (type as ParameterizedType).typeArguments.first;
      return ListFieldType(TransferFieldType.fromDartType(arg), nullable);
    } else if (type.isDartCoreMap) {
      final args = (type as ParameterizedType).typeArguments;
      if (!args.first.isDartCoreString) {
        throw Exception(
            'Only String keys are supported when using Map in Transfer Object.');
      }
      return MapFieldType(
          TransferFieldType.fromDartType(args.elementAt(1)), nullable);
    } else if (type.isTransferObject) {
      return ObjectFieldType(type.element2!.name!, nullable);
    } else if (type.isEnum) {
      return EnumFieldType(type.element2!.name!, nullable);
    } else {
      throw Exception('Invalid field type ${type.element2?.name}.');
    }
  }
}

class DynamicFieldType extends TransferFieldType {
  const DynamicFieldType() : super(false);

  @override
  final typeName = 'dynamic';
}

class StringFieldType extends TransferFieldType {
  const StringFieldType(super.nullable);

  @override
  final typeName = 'String';
}

class IntFieldType extends TransferFieldType {
  const IntFieldType(super.nullable);

  @override
  final typeName = 'int';
}

class DoubleFieldType extends TransferFieldType {
  const DoubleFieldType(super.nullable);

  @override
  final typeName = 'double';
}

class BoolFieldType extends TransferFieldType {
  const BoolFieldType(super.nullable);

  @override
  final typeName = 'bool';
}

class DateTimeFieldType extends TransferFieldType {
  const DateTimeFieldType(super.nullable);

  @override
  final typeName = 'DateTime';
}

class DurationFieldType extends TransferFieldType {
  const DurationFieldType(super.nullable);

  @override
  final typeName = 'Duration';
}

class ByteFieldType extends TransferFieldType {
  const ByteFieldType(super.nullable);

  @override
  final typeName = 'Uint8List';
}

class ListFieldType extends TransferFieldType {
  final TransferFieldType elementType;

  @override
  String get typeName => 'List<${elementType.typeNameNullability}>';

  const ListFieldType(this.elementType, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    return 'encodeListTyped<$typeNameNullability, ${elementType.typeNameNullability}>($valueAccessor)';
  }

  @override
  String buildDecodingStatement(String valueAccessor) {
    return 'decodeListTyped<$typeNameNullability, ${elementType.typeName}>($valueAccessor)';
  }
}

class MapFieldType extends TransferFieldType {
  final TransferFieldType valueType;

  const MapFieldType(this.valueType, super.nullable);

  @override
  String get typeName => 'Map<String, ${valueType.typeName}>';

  @override
  String buildEncodingStatement(String valueAccessor) {
    return 'encodeMapTyped<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor)';
  }

  @override
  String buildDecodingStatement(String valueAccessor) {
    return 'decodeMapTyped<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor)';
  }
}

class ObjectFieldType extends TransferFieldType {
  @override
  final String typeName;

  ObjectFieldType(this.typeName, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    return nullable ? '$valueAccessor?.toJson()' : '$valueAccessor.toJson()';
  }

  @override
  String buildDecodingStatement(String valueAccessor) {
    final decode = '${typeName}TransferBean.toObject($valueAccessor)';

    if (nullable) {
      return '(($valueAccessor) != null) ? $decode : null';
    }

    return decode;
  }
}

class EnumFieldType extends TransferFieldType {
  @override
  final String typeName;

  EnumFieldType(this.typeName, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    if (nullable) {
      return '$valueAccessor?.name';
    }

    return '$valueAccessor.name';
  }

  @override
  String buildDecodingStatement(String valueAccessor) {
    if (nullable) {
      return 'decodeEnumNullable($valueAccessor, $typeName.values)';
    }

    return 'decodeEnum($valueAccessor, $typeName.values)';
  }
}
