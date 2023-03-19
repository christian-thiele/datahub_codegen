import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_codegen/src/hub/resource_builders/resource_builder.dart';
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
      final builder = ResourceBuilder.get(field.type);
      yield* builder.buildProviderAccessor(field);
    }
  }

  Iterable<String> buildResourceListAccessor() sync* {
    final resources = resourceFields.map((e) => e.name).join(', ');
    yield '@override List<ResourceProvider> get resources => [$resources,];';
  }

  Iterable<String> buildResourceMethodStubs() sync* {
    for (final field in resourceFields) {
      final builder = ResourceBuilder.get(field.type);
      yield* builder.buildProviderMethodStubs(field);
    }
  }
}
