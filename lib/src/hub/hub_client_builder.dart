import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub_codegen/src/hub/resource_builders/collection_resource_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'resource_builders/resource_builder.dart';

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
      yield* ResourceBuilder.get(field.type).buildClientAccessor(field);
    }
  }
}
