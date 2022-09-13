import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_codegen/utils.dart';
import 'package:source_gen/source_gen.dart';

class HubClientBuilder {
  final String hubClass;
  final List<FieldElement> resourceFields;

  HubClientBuilder(this.hubClass, this.resourceFields);

  Iterable<String> build() sync* {
    yield 'class ${hubClass}Client extends HubClient<$hubClass> implements $hubClass {';
    yield 'final RestClient _client;';
    yield* buildConstructor();
    yield* buildResourceClientAccessors();
    yield '}';
  }

  Iterable<String> buildConstructor() sync* {
    yield '${hubClass}Client(this._client);';
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
            'Resource "${element.name}" does not provide HubResource annotation.'));

    final returnType = element.getter!.returnType;

    if (returnType.nullabilitySuffix != NullabilitySuffix.none) {
      throw Exception(
          'Resource "${element.name}" getter must be nun-nullable.');
    }

    final transferClass = (returnType as ParameterizedType).typeArguments.first;
    final bean = '${transferClass}TransferBean';

    final implementation =
        '${isMutable ? 'MutableResourceRestClient' : 'ResourceRestClient'}'
        '(_client, RoutePattern(\'${readField(annotation, 'path')}\'), $bean,)';

    final returnTypeName = returnType.getDisplayString(withNullability: false);

    yield '@override late final $returnTypeName ${element.name} = $implementation;';
  }
}
