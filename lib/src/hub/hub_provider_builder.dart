import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

class HubProviderBuilder {
  final String hubClass;
  final List<FieldElement> resourceFields;

  HubProviderBuilder(this.hubClass, this.resourceFields);

  Iterable<String> build() sync* {
    yield 'abstract class ${hubClass}Provider extends HubProvider<$hubClass> implements $hubClass {';
    yield* buildConstructor();
    yield* buildResourceClientAccessors();
    yield* buildResourceListAccessor();
    yield* buildResourceMethodStubs();
    yield '}';
  }

  Iterable<String> buildConstructor() sync* {
    yield '${hubClass}Provider();';
  }

  Iterable<String> buildResourceClientAccessors() sync* {
    for (final field in resourceFields) {
      yield* buildResourceClientAccessor(field);
    }
  }

  Iterable<String> buildResourceClientAccessor(FieldElement element) sync* {
    final isMutable = TypeChecker.fromRuntime(MutableResource)
        .isAssignableFromType(element.type);
    final annotation = getAnnotation(element.getter!, HubResource) ??
        (throw Exception(
            'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.'));

    final returnType = element.getter!.returnType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.');
    }

    final transferClass = (returnType as ParameterizedType).typeArguments.first;
    final bean = '${transferClass}TransferBean';

    final capitalizedName = _firstUpper(element.name);
    final methods = [
      'get$capitalizedName',
      if (isMutable) 'set$capitalizedName',
      'get${capitalizedName}Stream',
    ].join(', ');

    final implementation =
        '${isMutable ? 'MutableResourceAdapter' : 'ResourceAdapter'}'
        '(RoutePattern(\'${readField(annotation, 'path')}\'), $bean, $methods,)';

    final returnTypeName = returnType.getDisplayString(withNullability: false);

    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }

  String _firstUpper(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value.substring(0, 1).toUpperCase() + value.substring(1);
  }

  Iterable<String> buildResourceListAccessor() sync* {
    final resources = resourceFields.map((e) => e.name).join(', ');

    yield '@override List<Resource> get resources => [$resources,];';
  }

  Iterable<String> buildResourceMethodStubs() sync* {
    for (final field in resourceFields) {
      yield* buildSingleResourceMethodStubs(field);
    }
  }

  Iterable<String> buildSingleResourceMethodStubs(FieldElement element) sync* {
    final isMutable = TypeChecker.fromRuntime(MutableResource)
        .isAssignableFromType(element.type);

    final returnType = element.getter!.returnType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.getDisplayString(withNullability: false)}" does not provide HubResource annotation.');
    }

    final transferClass = (returnType as ParameterizedType).typeArguments.first;
    final capitalizedName = _firstUpper(element.name);

    yield 'Future<$transferClass> get$capitalizedName(Map<String, String> params);';

    if (isMutable) {
      yield 'Future<void> set$capitalizedName($transferClass value, Map<String, String> params);';
    }

    yield 'Stream<$transferClass> get${capitalizedName}Stream(Map<String, String> params);';
  }
}
