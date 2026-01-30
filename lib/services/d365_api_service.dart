import '../core/d365_http_client.dart';
import '../models/dropdown_item.dart';

class D365ApiService {
  final String resource;
  final D365HttpClient client;

  D365ApiService(this.resource, this.client);

  Future<List<Map<String, dynamic>>> getEntity(String entity) {
    return client.get(
      '$resource/data/$entity',
      (json) => List<Map<String, dynamic>>.from(json['value']),
    );
  }

  Future<void> createEntity(String entity, Map<String, dynamic> payload) {
    return client.post('$resource/data/$entity', payload, (_) => null);
  }

  Future<void> updateEntity(
    String entity,
    String keyField,
    String keyValue,
    Map<String, dynamic> payload,
  ) {
    return client.patch(
      '$resource/data/$entity($keyField=\'$keyValue\')',
      payload,
    );
  }

  Future<List<DropdownItem>> dropdown({
    required String entity,
    required String keyField,
    required String displayField,
  }) {
    return getEntity(entity).then(
      (list) => list
          .map((e) => DropdownItem(
                key: e[keyField].toString(),
                value: e[displayField].toString(),
              ))
          .toList(),
    );
  }
}
