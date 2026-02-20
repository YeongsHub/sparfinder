class ApiConstants {
  static const String marktguruBaseUrl = 'https://api.marktguru.de';
  static const String marktguruSearchPath = '/api/v1/offers/search';

  // 실제 marktguru 앱에서 역공학으로 확인된 인증 키
  static const Map<String, String> marktguruHeaders = {
    'x-clientkey': 'WU/RH+PMGDi+gkZer3WbMelt6zcYHSTytNB7VpTia90=',
    'x-apikey': '8Kk+pmbf7TgJ9nVj2cXeA7P5zBGv8iuutVVMRfOfvNE=',
    'Content-Type': 'application/json',
  };

  static const int defaultLimit = 50;
  static const String defaultZipCode = '10115'; // Berlin Mitte (기본값)
}
