import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/constants/supermarket_constants.dart';
import '../../core/theme/app_theme.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isCheapest;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const OfferCard({
    super.key,
    required this.offer,
    this.isCheapest = false,
    this.isSaved = false,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final info = SupermarketConstants.getInfo(offer.supermarketName);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Stack(
              children: [
                _buildImage(),
                if (isCheapest)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bestDealGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'BEST DEAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (offer.hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        PriceFormatter.discountPercent(
                            offer.originalPrice!, offer.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // 정보 영역
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 슈퍼마켓 이름
                  Row(
                    children: [
                      Text(info.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        offer.supermarketName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(info.color),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 상품명
                  Text(
                    offer.displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (offer.unit != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      offer.unit!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PriceFormatter.format(offer.price),
                            style: TextStyle(
                              fontSize: 16,
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
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: onSave,
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: isSaved
                              ? AppTheme.primaryGreen
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = offer.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          _categoryIcon(),
          size: 40,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  IconData _categoryIcon() {
    final cat = offer.category?.toLowerCase() ?? '';
    if (cat.contains('milch') || cat.contains('käse')) return Icons.egg_outlined;
    if (cat.contains('fleisch') || cat.contains('wurst')) return Icons.restaurant;
    if (cat.contains('obst') || cat.contains('gemüse')) return Icons.eco;
    if (cat.contains('getränk') || cat.contains('drink')) return Icons.local_drink;
    if (cat.contains('brot') || cat.contains('back')) return Icons.bakery_dining;
    if (cat.contains('fisch')) return Icons.set_meal;
    return Icons.shopping_basket;
  }
}
