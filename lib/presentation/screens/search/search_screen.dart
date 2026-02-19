import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_formatter.dart';
import '../../widgets/price_comparison_row.dart';
import 'search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    'Milch', 'Butter', 'Eier', 'Brot', 'Käse',
    'Hähnchen', 'Lachs', 'Bananen', 'Cola', 'Joghurt',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchQueryProvider.notifier).state = query.trim();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preisvergleich'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Produkt suchen (z.B. Milch, Brot...)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Expanded(
            child: query.isEmpty
                ? _buildSuggestions()
                : results.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('Fehler beim Suchen: $e'),
                        ],
                      ),
                    ),
                    data: (offers) => offers.isEmpty
                        ? _buildNoResults(query)
                        : _buildResults(offers),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beliebte Suchen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () {
                  _controller.text = s;
                  _search(s);
                },
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Keine Angebote für "$query"',
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Versuche einen anderen Suchbegriff',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List offers) {
    final cheapest = offers.first;
    final mostExpensive = offers.last;
    final savings = mostExpensive.price - cheapest.price;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 요약 배너
        if (offers.length > 1)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bis zu sparen:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      PriceFormatter.format(savings),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'bei ${cheapest.supermarketName} kaufen',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // 결과 헤더
        Text(
          '${offers.length} Angebote für "${ref.watch(searchQueryProvider)}"',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // 가격 비교 리스트
        ...offers.asMap().entries.map((entry) {
          final index = entry.key;
          final offer = entry.value;
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              '/product',
              arguments: offer,
            ),
            child: PriceComparisonRow(
              offer: offer,
              rank: index + 1,
              isCheapest: index == 0,
            ),
          );
        }),
      ],
    );
  }
}
