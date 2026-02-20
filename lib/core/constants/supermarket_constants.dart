class SupermarketConstants {
  static const Map<String, SupermarketInfo> supermarkets = {
    'aldi': SupermarketInfo(
      id: 'aldi',
      name: 'ALDI',
      color: 0xFF005DA8,
      emoji: '🔵',
    ),
    'aldisüd': SupermarketInfo(
      id: 'aldisüd',
      name: 'ALDI Süd',
      color: 0xFF005DA8,
      emoji: '🔵',
    ),
    'aldinord': SupermarketInfo(
      id: 'aldinord',
      name: 'ALDI Nord',
      color: 0xFF003F7A,
      emoji: '🔵',
    ),
    'lidl': SupermarketInfo(
      id: 'lidl',
      name: 'LIDL',
      color: 0xFFFFD800,
      emoji: '🟡',
    ),
    'rewe': SupermarketInfo(
      id: 'rewe',
      name: 'REWE',
      color: 0xFFCC0000,
      emoji: '🔴',
    ),
    'kaufland': SupermarketInfo(
      id: 'kaufland',
      name: 'Kaufland',
      color: 0xFFE30613,
      emoji: '🏪',
    ),
    'penny': SupermarketInfo(
      id: 'penny',
      name: 'Penny',
      color: 0xFFCC0000,
      emoji: '🟢',
    ),
    'netto': SupermarketInfo(
      id: 'netto',
      name: 'Netto',
      color: 0xFFFFCC00,
      emoji: '🟠',
    ),
    'edeka': SupermarketInfo(
      id: 'edeka',
      name: 'EDEKA',
      color: 0xFF005E3C,
      emoji: '💚',
    ),
    'tegut': SupermarketInfo(
      id: 'tegut',
      name: 'tegut',
      color: 0xFFE8500A,
      emoji: '🟠',
    ),
  };

  /// API 결과에서 슈퍼마켓 여부 판별
  /// 'ALDI Süd', 'REWE City', 'Netto Marken-Discount' 등 변형도 포함
  static bool isKnownSupermarket(String name) {
    final key = name.toLowerCase().replaceAll(' ', '');
    return supermarkets.keys.any((k) => key.contains(k));
  }

  static SupermarketInfo getInfo(String name) {
    final key = name.toLowerCase().replaceAll(' ', '');
    return supermarkets[key] ??
        SupermarketInfo(
          id: key,
          name: name,
          color: 0xFF888888,
          emoji: '🛒',
        );
  }
}

class SupermarketInfo {
  final String id;
  final String name;
  final int color;
  final String emoji;

  const SupermarketInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.emoji,
  });
}