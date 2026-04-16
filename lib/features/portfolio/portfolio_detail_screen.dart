import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/fund_entry_item.dart';
import '../../core/models/portfolio_item.dart';
import '../../core/models/roi_entry.dart';
import '../../shared/widgets/app_card.dart';
import '../client/client_api.dart';

class PortfolioDetailScreen extends StatelessWidget {
  const PortfolioDetailScreen({super.key, required this.portfolio});

  final PortfolioItem portfolio;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ClientApi>();

    return Scaffold(
      appBar: AppBar(title: Text(portfolio.portfolioNumber)),
      body: FutureBuilder<_PortfolioDetailBundle>(
        future: _load(api),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bundle = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(portfolio.portfolioType,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text(portfolio.portfolioNumber,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Text('Group: ${portfolio.groupCode ?? '—'}'),
                    Text('Payment Date: ${portfolio.paymentDate ?? '—'}'),
                    Text('Start: ${AppFormatters.date(portfolio.startDate)}'),
                    Text(
                        'Maturity: ${AppFormatters.date(portfolio.maturityDate)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Portfolio Summary',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Text(
                        'Invested Amount: ${AppFormatters.currency(portfolio.initialInvestment)}'),
                    Text(
                        'Current Capital: ${AppFormatters.currency(portfolio.currentCapital)}'),
                    Text(
                        'ROI Paid: ${AppFormatters.currency(portfolio.totalRoiPaid)}'),
                    Text(
                        'ROI Unpaid: ${AppFormatters.currency(portfolio.totalRoiUnpaid)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROI Ledger',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    ...bundle.roiEntries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${entry.month}/${entry.year}'),
                            subtitle: Text(entry.paymentStatus),
                            trailing:
                                Text(AppFormatters.currency(entry.roiAmount)),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Funds Manager',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    ...bundle.fundEntries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${entry.fundType} - ${entry.stockName ?? 'No stock'}'),
                            subtitle: Text(
                                '${entry.status} • ${AppFormatters.date(entry.entryDate ?? entry.timestamp)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(AppFormatters.currency(entry.amount)),
                                Text(
                                    AppFormatters.percent(entry.pnlPercentage)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_PortfolioDetailBundle> _load(ClientApi api) async {
    final roiEntries = await api.getPortfolioRoi(portfolio.id);
    final fundEntries =
        await api.getFundEntries(portfolioId: portfolio.id, status: 'Open');
    return _PortfolioDetailBundle(
        roiEntries: roiEntries, fundEntries: fundEntries);
  }
}

class _PortfolioDetailBundle {
  _PortfolioDetailBundle({required this.roiEntries, required this.fundEntries});

  final List<RoiEntry> roiEntries;
  final List<FundEntryItem> fundEntries;
}
