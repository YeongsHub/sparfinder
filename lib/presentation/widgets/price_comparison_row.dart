import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/constants/supermarket_constants.dart';
import '../../core/theme/app_theme.dart';

class PriceComparisonRow extends StatelessWidget {
  final Offer offer;
  final bool isCheapest;
  final int rank;

  const PriceComparisonRow({
    super.key,
    required this.offer,
    required this.rank,
    this.isCheapest = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = SupermarketConstants.getInfo(offer.supermarketName);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCheapest
            ? AppTheme.primaryGreen.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCheapest
            ? Border.all(color: AppTheme.primaryGreen, width: 1.5)
            : Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 순위
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCheapest ? AppTheme.primaryGreen : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isCheapest ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 슈퍼마켓 + 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 슈퍼마켓명 + 카테고리 태그
                Row(
                  children: [
                    Text(info.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.supermarketName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCheapest
                              ? AppTheme.primaryGreen
                              : Color(info.color),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (offer.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor(offer.category!)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _categoryShort(offer.category!),
                          style: TextStyle(
                            fontSize: 9,
                            color: _categoryColor(offer.category!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                // 상품명
                Text(
                  offer.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (offer.unit != null)
                  Text(
                    offer.unit!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 가격
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.format(offer.price),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCheapest
                      ? AppTheme.primaryGreen
                      : AppTheme.textPrimary,
                ),
              ),
              if (offer.originalPrice != null)
                Text(
                  PriceFormatter.format(offer.originalPrice!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          if (isCheapest) ...[
            const SizedBox(width: 8),
            const Icon(Icons.star, color: AppTheme.bestDealGold, size: 20),
          ],
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('milch') || cat.contains('käse') || cat.contains('joghurt')) return Colors.blue;
    if (cat.contains('fleisch') || cat.contains('wurst') || cat.contains('fisch')) return Colors.red[700]!;
    if (cat.contains('obst') || cat.contains('gemüse')) return Colors.green[700]!;
    if (cat.contains('getränk') || cat.contains('bier') || cat.contains('wein')) return Colors.indigo;
    if (cat.contains('brot') || cat.contains('back')) return Colors.orange[700]!;
    if (cat.contains('tiefkühl')) return Colors.cyan[700]!;
    if (cat.contains('süß') || cat.contains('schoko') || cat.contains('chips')) return Colors.pink[600]!;
    return Colors.grey[600]!;
  }

  String _categoryShort(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('milch')) return 'Milch';
    if (cat.contains('käse')) return 'Käse';
    if (cat.contains('joghurt')) return 'Joghurt';
    if (cat.contains('fleisch')) return 'Fleisch';
    if (cat.contains('wurst') || cat.contains('schinken')) return 'Wurst';
    if (cat.contains('fisch') || cat.contains('lachs')) return 'Fisch';
    if (cat.contains('obst')) return 'Obst';
    if (cat.contains('gemüse')) return 'Gemüse';
    if (cat.contains('getränk')) return 'Getränke';
    if (cat.contains('bier')) return 'Bier';
    if (cat.contains('wein')) return 'Wein';
    if (cat.contains('brot') || cat.contains('back')) return 'Brot';
    if (cat.contains('tiefkühl')) return 'TK';
    if (cat.contains('schoko')) return 'Süßes';
    if (cat.contains('eier')) return 'Eier';
    if (cat.contains('kaffee')) return 'Kaffee';
    return category.length > 8 ? '${category.substring(0, 8)}…' : category;
  }
}