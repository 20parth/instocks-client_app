import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/fund_entry_item.dart';
import '../../core/models/portfolio_item.dart';
import '../../core/models/roi_entry.dart';
import '../../shared/widgets/glass_card.dart';
import '../client/client_api.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  int? _portfolioId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<ClientApi>();
    final theme = Theme.of(context);

    return SafeArea(
      child: FutureBuilder<List<PortfolioItem>>(
        future: api.getPortfolios(),
        builder: (context, portfoliosSnapshot) {
          if (!portfoliosSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final portfolios = portfoliosSnapshot.data!;
          _portfolioId ??= portfolios.isNotEmpty ? portfolios.first.id : null;

          if (_portfolioId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Portfolios Found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No linked portfolios available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<_ReportsBundle>(
            future: _load(api, _portfolioId!, _dateFrom, _dateTo),
            builder: (context, bundleSnapshot) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Reports',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'View detailed statements, ROI history, and fund activity',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Portfolio selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            value: _portfolioId,
                            items: portfolios
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(
                                      '${item.portfolioNumber} - ${item.portfolioType}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _portfolioId = value),
                            decoration: InputDecoration(
                              labelText: 'Select Portfolio',
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet_rounded,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final value = await showDatePicker(
                                      context: context,
                                      initialDate: _dateFrom ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (value != null) {
                                      setState(() => _dateFrom = value);
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today,
                                      size: 18),
                                  label: Text(
                                    _dateFrom == null
                                        ? 'From'
                                        : AppFormatters.date(
                                            _dateFrom!.toIso8601String(),
                                          ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final value = await showDatePicker(
                                      context: context,
                                      initialDate: _dateTo ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (value != null) {
                                      setState(() => _dateTo = value);
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today,
                                      size: 18),
                                  label: Text(
                                    _dateTo == null
                                        ? 'To'
                                        : AppFormatters.date(
                                            _dateTo!.toIso8601String(),
                                          ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      unselectedLabelColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Statement'),
                        Tab(text: 'ROI'),
                        Tab(text: 'Funds'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab views
                  Expanded(
                    child: bundleSnapshot.hasData
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              _buildStatementTab(
                                context,
                                bundleSnapshot.data!.transactions,
                              ),
                              _buildRoiTab(
                                context,
                                bundleSnapshot.data!.roiEntries,
                              ),
                              _buildFundsTab(
                                context,
                                bundleSnapshot.data!.funds,
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatementTab(
    BuildContext context,
    List<Map<String, dynamic>> transactions,
  ) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.receipt_long_rounded,
        'No Transactions',
        'No statement activity found for the selected period',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final type =
            transaction['transaction_type']?.toString() ?? 'Transaction';
        final amount =
            double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
        final date = transaction['transaction_date']?.toString() ??
            transaction['created_at']?.toString();

        return AnimatedGlassCard(
          delay: Duration(milliseconds: index * 50),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTransactionIcon(type),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.date(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AppFormatters.currency(amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amount >= 0
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoiTab(BuildContext context, List<RoiEntry> roiEntries) {
    final theme = Theme.of(context);

    if (roiEntries.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.trending_up_rounded,
        'No ROI Data',
        'No ROI entries found for this portfolio',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: roiEntries.length,
      itemBuilder: (context, index) {
        final roi = roiEntries[index];

        return AnimatedGlassCard(
          delay: Duration(milliseconds: index * 50),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.savings_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${roi.month}/${roi.year}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roi.paymentStatus,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.currency(roi.roiAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              if (roi.paymentDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment: ${roi.paymentStatus}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        AppFormatters.date(roi.paymentDate!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundsTab(BuildContext context, List<FundEntryItem> funds) {
    final theme = Theme.of(context);

    if (funds.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.account_balance_rounded,
        'No Fund Entries',
        'No fund activity found for this portfolio',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: funds.length,
      itemBuilder: (context, index) {
        final fund = funds[index];

        return AnimatedGlassCard(
          delay: Duration(milliseconds: index * 50),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.fundType,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fund.stockName ?? 'No stock',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: fund.status.toLowerCase() == 'open'
                                ? theme.colorScheme.tertiaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            fund.status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.date(
                            fund.entryDate ?? fund.timestamp,
                          ),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                AppFormatters.currency(fund.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('invest') || lowerType.contains('deposit')) {
      return Icons.arrow_downward_rounded;
    } else if (lowerType.contains('withdraw')) {
      return Icons.arrow_upward_rounded;
    } else if (lowerType.contains('roi')) {
      return Icons.trending_up_rounded;
    }
    return Icons.swap_horiz_rounded;
  }

  Future<_ReportsBundle> _load(
    ClientApi api,
    int portfolioId,
    DateTime? dateFrom,
    DateTime? dateTo,
  ) async {
    final statement = await api.getPortfolioStatement(
      portfolioId,
      dateFrom: dateFrom?.toIso8601String().split('T').first,
      dateTo: dateTo?.toIso8601String().split('T').first,
    );
    final roiEntries = await api.getPortfolioRoi(portfolioId);
    final funds = await api.getFundEntries(portfolioId: portfolioId);

    return _ReportsBundle(
      transactions: List<Map<String, dynamic>>.from(
        statement['transactions'] as List<dynamic>? ?? const [],
      ),
      roiEntries: roiEntries,
      funds: funds,
    );
  }
}

class _ReportsBundle {
  _ReportsBundle({
    required this.transactions,
    required this.roiEntries,
    required this.funds,
  });

  final List<Map<String, dynamic>> transactions;
  final List<RoiEntry> roiEntries;
  final List<FundEntryItem> funds;
}
