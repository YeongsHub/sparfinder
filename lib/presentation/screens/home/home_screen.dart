import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/offer_card.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categories = [
    'Alle',
    'Milchprodukte',
    'Fleisch',
    'Obst & Gemüse',
    'Getränke',
    'Brot & Backwaren',
    'Fisch',
    'Eier',
    'Käse',
    'Frühstück',
  ];

  void _showZipDialog(BuildContext context, WidgetRef ref, String currentZip) {
    final controller = TextEditingController(text: currentZip);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Postleitzahl ändern'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'z.B. 10115',
            prefixIcon: Icon(Icons.location_on),
            counterText: '',
          ),
          onSubmitted: (v) {
            _saveZip(context, ref, v);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveZip(context, ref, controller.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _saveZip(BuildContext context, WidgetRef ref, String zip) {
    final trimmed = zip.trim();
    if (trimmed.length != 5 || int.tryParse(trimmed) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte eine gültige 5-stellige PLZ eingeben'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ref.read(zipCodeProvider.notifier).state = trimmed;
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString('zipCode', trimmed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Angebote für PLZ $trimmed werden geladen...'),
        backgroundColor: AppTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zipCode = ref.watch(zipCodeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final weeklyDeals = ref.watch(weeklyDealsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.primaryGreen,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SparFinder 🛒',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // PLZ 클릭 가능한 버튼
                GestureDetector(
                  onTap: () => _showZipDialog(context, ref, zipCode),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'PLZ $zipCode',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.white54, size: 12),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _CategoryFilter(
                categories: _categories,
                selected: selectedCategory ?? 'Alle',
                onSelect: (cat) {
                  ref.read(selectedCategoryProvider.notifier).state =
                      cat == 'Alle' ? null : cat;
                },
              ),
            ),
          ),

          // 이번 주 특가 헤더
          weeklyDeals.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (deals) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'Diese Woche im Angebot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${deals.length} Produkte',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 딜 그리드
          weeklyDeals.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Fehler: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(weeklyDealsProvider),
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
            data: (deals) {
              if (deals.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Keine Angebote gefunden'),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final homeDeal = deals[index];
                      final offer = homeDeal.cheapest;
                      final savedOffers = ref.watch(savedOffersProvider);
                      final isSaved = savedOffers.contains(offer.id);
                      return OfferCard(
                        offer: offer,
                        storeCount: homeDeal.storeCount,
                        isSaved: isSaved,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/product',
                          arguments: offer,
                        ),
                        onSave: () => ref
                            .read(savedOffersProvider.notifier)
                            .toggle(offer.id),
                      );
                    },
                    childCount: deals.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => onSelect(cat),
            selectedColor: AppTheme.primaryGreen,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
