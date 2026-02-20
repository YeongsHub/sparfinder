import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';
import '../../core/utils/price_formatter.dart';
import '../../core/constants/supermarket_constants.dart';
import '../../core/theme/app_theme.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isCheapest;
  final bool isSaved;
  final int storeCount;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const OfferCard({
    super.key,
    required this.offer,
    this.isCheapest = false,
    this.isSaved = false,
    this.storeCount = 1,
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
        // Column이 그리드 셀 높이를 꽉 채우도록 Expanded 구조 사용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역 (고정 높이)
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
            // 정보 영역 — 남은 공간을 모두 차지하되 overflow 없이
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 슈퍼마켓 이름 + 카테고리 태그
                    Row(
                      children: [
                        Text(info.emoji,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            offer.supermarketName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(info.color),
                              fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 4),
                    // 상품명
                    Text(
                      offer.displayName,
                      style: const TextStyle(
                        fontSize: 12,
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
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    // 가격 + 북마크를 하단에 고정
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PriceFormatter.format(offer.price),
                              style: TextStyle(
                                fontSize: 15,
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
                                  fontSize: 10,
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
                    // 여러 마켓 비교 배지
                    if (storeCount > 1) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.compare_arrows,
                                size: 10, color: Colors.blue[600]),
                            const SizedBox(width: 3),
                            Text(
                              '$storeCount Märkte',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // 유효기간
                    if (offer.validUntil != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'bis ${_formatDate(offer.validUntil!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: _isExpiringSoon(offer.validUntil!)
                              ? Colors.orange[700]
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
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
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 100,
          width: double.infinity,
          color: Colors.grey[100],
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _placeholder(),
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

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.';
  }

  bool _isExpiringSoon(DateTime date) {
    return date.difference(DateTime.now()).inDays <= 2;
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
    // 긴 카테고리명은 앞 8자까지만
    return category.length > 8 ? '${category.substring(0, 8)}…' : category;
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