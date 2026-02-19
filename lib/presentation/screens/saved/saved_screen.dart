import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          if (savedIds.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Liste leeren?'),
                    content: const Text(
                        'Alle gespeicherten Produkte werden entfernt.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () {
                          for (final id in List.from(savedIds)) {
                            ref
                                .read(savedOffersProvider.notifier)
                                .toggle(id);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Leeren',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Alle entfernen',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: savedIds.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedIds.length,
              itemBuilder: (context, index) {
                final id = savedIds[index];
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_basket,
                          color: AppTheme.primaryGreen),
                    ),
                    title: Text('Produkt $id'),
                    subtitle: const Text('Angebot gespeichert'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      onPressed: () => ref
                          .read(savedOffersProvider.notifier)
                          .toggle(id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Keine gespeicherten Produkte',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tippe auf das Lesezeichen-Symbol\num Produkte zu speichern',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
