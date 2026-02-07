class ApiConstants {
  static const String baseUrl = 'https://api.superthread.com/v1';
  static const String websocketUrl = 'wss://api.superthread.com/realtime';

  // API Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String me = '/users/me';
  static const String cards = '/cards';
  static const String projects = '/projects';
  static const String epics = '/epics'; // Projects are called Epics in the API
  static const String boards = '/boards';
  static const String notes = '/notes';
  static const String pages = '/pages';
  static const String comments = '/comments';
  static const String sprints = '/sprints';
  static const String spaces = '/spaces';
  static const String tags = '/tags';
  static const String search = '/search';

  // Headers
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}