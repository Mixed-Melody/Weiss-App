import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/collection_provider.dart';
import '../services/price_scraper.dart';

/// Displays high-level statistics about the user's collection along with
/// summary charts.  The dashboard also allows the user to run the price and
/// image scraper manually.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _scraping = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionProvider>(
      builder: (context, provider, child) {
        final totalValue = provider.totalValue;
        final cardCount = provider.cards.length;
        final deckCount = provider.decks.length;
        final wishlistCount = provider.wishlistedCount;
        final colorDist = provider.colorDistribution;

        final sections = <PieChartSectionData>[];
        final colors = [
          Colors.yellow.shade600,
          Colors.green.shade600,
          Colors.red.shade600,
          Colors.blue.shade600,
          Colors.orange.shade600,
          Colors.purple.shade600,
        ];
        int index = 0;
        colorDist.forEach((color, count) {
          final value = count.toDouble();
          final sectionColor = index < colors.length ? colors[index] : Colors.grey;
          sections.add(PieChartSectionData(
            color: sectionColor,
            value: value,
            title: value.toInt().toString(),
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ));
          index++;
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3.5,
                    children: [
                      _buildSummaryCard(
                        context: context,
                        title: 'Total Value',
                        value: '\$${totalValue.toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: Colors.indigo,
                      ),
                      _buildSummaryCard(
                        context: context,
                        title: 'Cards',
                        value: cardCount.toString(),
                        icon: Icons.style,
                        color: Colors.green,
                      ),
                      _buildSummaryCard(
                        context: context,
                        title: 'Decks',
                        value: deckCount.toString(),
                        icon: Icons.collections_bookmark,
                        color: Colors.orange,
                      ),
                      _buildSummaryCard(
                        context: context,
                        title: 'Wishlist',
                        value: wishlistCount.toString(),
                        icon: Icons.favorite,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Colour Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                    const SizedBox(height: 16),
                  colorDist.isEmpty
                      ? const Text('No cards in collection')
                      : SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                              // Add a legend underneath the chart.
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      for (var entry in colorDist.entries)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[colorDist.keys.toList().indexOf(entry.key) % colors.length],
                              ),
                            ),
                            Text('${entry.key} (${entry.value})'),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _scraping
                            ? null
                            : () async {
                                setState(() {
                                  _scraping = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Running scraper. Please wait...')),
                                );
                                try {
                                  await PriceScraper.instance.updateAll();
                                  await provider.reloadAll();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Scrape completed.')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Scrape failed: $e')),
                                  );
                                }
                                setState(() {
                                  _scraping = false;
                                });
                              },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Run Scraper'),
                      ),
                      const SizedBox(width: 16),
                      if (_scraping) const CircularProgressIndicator(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a small summary card with an icon, a title and a value.  These
  /// cards are used at the top of the dashboard to quickly convey high‑level
  /// metrics.  Consider using animations or modern neumorphic designs here.
  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}