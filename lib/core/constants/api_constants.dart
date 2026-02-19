class ApiConstants {
  static const String marktguruBaseUrl = 'https://api.marktguru.de';
  static const String marktguruSearchPath = '/api/v1/offers/search';
  static const String marktguruListPath = '/api/v1/offers/list';

  static const Map<String, String> marktguruHeaders = {
    'X-Apikey': 'mf7zcN2MKY78dF9smdRaRKz3LNHndFAU',
    'Content-Type': 'application/json',
  };

  static const int defaultLimit = 100;
  static const String defaultZipCode = '10115'; // Berlin Mitte (기본값)
}
