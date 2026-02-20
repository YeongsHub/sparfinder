import 'secrets.dart';

class ApiConstants {
  static const String marktguruBaseUrl = 'https://api.marktguru.de';
  static const String marktguruSearchPath = '/api/v1/offers/search';

  static const Map<String, String> marktguruHeaders = {
    'x-clientkey': Secrets.marktguruClientKey,
    'x-apikey': Secrets.marktguruApiKey,
    'Content-Type': 'application/json',
  };

  static const int defaultLimit = 50;
  static const String defaultZipCode = '10115'; // Berlin Mitte (기본값)
}
