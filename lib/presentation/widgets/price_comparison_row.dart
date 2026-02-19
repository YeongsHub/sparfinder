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
          // 슈퍼마켓 정보
          Expanded(
            child: Row(
              children: [
                Text(info.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.supermarketName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isCheapest
                            ? AppTheme.primaryGreen
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (offer.unit != null)
                      Text(
                        offer.unit!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 가격
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.format(offer.price),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCheapest ? AppTheme.primaryGreen : AppTheme.textPrimary,
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
}
