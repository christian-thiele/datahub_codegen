import 'package:datahub/datahub.dart';

import '../transfer_object/contact.dart';

part 'test_hub.g.dart';

@Hub()
abstract class TestHub {
  @HubResource('/contact/{id}')
  Resource<Contact> get contact;

  @HubResource('/self')
  MutableResource<Contact> get self;
}
