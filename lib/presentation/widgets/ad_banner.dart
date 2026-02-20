import 'package:flutter/material.dart';

/// 광고 플레이스홀더 — AdMob 연동 전 UI 확인용
/// 실제 연동 시 BannerAd 위젯으로 교체하면 됨
class AdBannerWidget extends StatelessWidget {
  final double height;

  const AdBannerWidget({super.key, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'Anzeige',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Werbung',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}