import '../../../core/network/api_client.dart';

class EventsApi {
  EventsApi(this._client);

  final ApiClient _client;

  Future<dynamic> getEvents() {
    return _client.get<dynamic>('/events');
  }

  Future<dynamic> getEventById(String id) {
    return _client.get<dynamic>('/events/$id');
  }
}
