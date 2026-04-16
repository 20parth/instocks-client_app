import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/portfolio_item.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/metric_tile.dart';
import '../auth/session_controller.dart';
import '../client/client_api.dart';
import '../portfolio/portfolio_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final api = context.read<ClientApi>();
    final summary = await api.getClientSummary();
    final portfolios = await api.getPortfolios();
    final notifications = await api.getNotifications();

    return _DashboardData(
      summary: summary,
      portfolios: portfolios,
      unreadNotifications: notifications.where((item) => !item.isRead).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;

    return SafeArea(
      child: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final summary =
              data.summary['summary'] as Map<String, dynamic>? ?? {};
          final totalCapital =
              (summary['current_capital'] as num?)?.toDouble() ?? 0;
          final totalRoi = (summary['total_roi'] as num?)?.toDouble() ?? 0;
          final totalWithdrawals =
              (summary['total_withdrawals'] as num?)?.toDouble() ?? 0;

          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Welcome, ${user?.fullName.split(' ').first ?? 'Client'}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    'Track your linked portfolios, ROI, funds, reports, and alerts in one client-only mobile workspace.'),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Instocks Client Overview'),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                              child: MetricTile(
                                  label: 'Portfolios',
                                  value: '${data.portfolios.length}',
                                  icon: Icons.account_balance_wallet_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: MetricTile(
                                  label: 'Unread Alerts',
                                  value: '${data.unreadNotifications}',
                                  icon: Icons.notifications_active_rounded)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: MetricTile(
                                  label: 'Current Capital',
                                  value: AppFormatters.currency(totalCapital),
                                  icon: Icons.savings_rounded)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: MetricTile(
                                  label: 'Total ROI',
                                  value: AppFormatters.currency(totalRoi),
                                  icon: Icons.trending_up_rounded)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 42,
                        sections: [
                          PieChartSectionData(
                              value: totalCapital <= 0 ? 1 : totalCapital,
                              color: const Color(0xFF37C6F4),
                              title: 'Capital'),
                          PieChartSectionData(
                              value: totalRoi <= 0 ? 1 : totalRoi,
                              color: const Color(0xFF69F0AE),
                              title: 'ROI'),
                          PieChartSectionData(
                              value:
                                  totalWithdrawals <= 0 ? 1 : totalWithdrawals,
                              color: const Color(0xFFFFC857),
                              title: 'Withdrawals'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('My Portfolios',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...data.portfolios.map((portfolio) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PortfolioPreviewCard(portfolio: portfolio),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PortfolioPreviewCard extends StatelessWidget {
  const _PortfolioPreviewCard({required this.portfolio});

  final PortfolioItem portfolio;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PortfolioDetailScreen(portfolio: portfolio)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(portfolio.portfolioType,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 4),
                    Text(portfolio.portfolioNumber,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Chip(label: Text(portfolio.status)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
              'Current Capital: ${AppFormatters.currency(portfolio.currentCapital)}'),
          Text('Total ROI: ${AppFormatters.currency(portfolio.totalRoi)}'),
          Text('Payment Date: ${portfolio.paymentDate ?? '—'}'),
        ],
      ),
    );
  }
}

class _DashboardData {
  _DashboardData({
    required this.summary,
    required this.portfolios,
    required this.unreadNotifications,
  });

  final Map<String, dynamic> summary;
  final List<PortfolioItem> portfolios;
  final int unreadNotifications;
}
