import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/fund_entry_item.dart';
import '../../core/models/portfolio_item.dart';
import '../../core/models/roi_entry.dart';
import '../../shared/widgets/app_card.dart';
import '../client/client_api.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _portfolioId;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ClientApi>();

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
            return const Center(child: Text('No linked portfolios available.'));
          }

          return FutureBuilder<_ReportsBundle>(
            future: _load(api, _portfolioId!, _dateFrom, _dateTo),
            builder: (context, bundleSnapshot) {
              if (!bundleSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final bundle = bundleSnapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('My Reports',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text(
                      'Review one portfolio at a time with statement activity, ROI history, and fund entries.'),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _portfolioId,
                          items: portfolios
                              .map((item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(
                                      '${item.portfolioNumber} - ${item.portfolioType}')))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _portfolioId = value),
                          decoration:
                              const InputDecoration(labelText: 'Portfolio'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final value = await showDatePicker(
                                    context: context,
                                    initialDate: _dateFrom ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (value != null)
                                    setState(() => _dateFrom = value);
                                },
                                child: Text(_dateFrom == null
                                    ? 'From Date'
                                    : AppFormatters.date(
                                        _dateFrom!.toIso8601String())),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final value = await showDatePicker(
                                    context: context,
                                    initialDate: _dateTo ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (value != null)
                                    setState(() => _dateTo = value);
                                },
                                child: Text(_dateTo == null
                                    ? 'To Date'
                                    : AppFormatters.date(
                                        _dateTo!.toIso8601String())),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statement Activity',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...bundle.transactions.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                  item['transaction_type']?.toString() ??
                                      'Transaction'),
                              subtitle: Text(AppFormatters.date(
                                  item['transaction_date']?.toString())),
                              trailing: Text(AppFormatters.currency(
                                  (item['amount'] as num?)?.toDouble() ?? 0)),
                            )),
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
                        const SizedBox(height: 12),
                        ...bundle.roiEntries.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${item.month}/${item.year}'),
                              subtitle: Text(item.paymentStatus),
                              trailing:
                                  Text(AppFormatters.currency(item.roiAmount)),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Funds Activity',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...bundle.funds.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                  '${item.fundType} - ${item.stockName ?? 'No stock'}'),
                              subtitle: Text(
                                  '${item.status} • ${AppFormatters.date(item.entryDate ?? item.timestamp)}'),
                              trailing:
                                  Text(AppFormatters.currency(item.amount)),
                            )),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<_ReportsBundle> _load(ClientApi api, int portfolioId,
      DateTime? dateFrom, DateTime? dateTo) async {
    final statement = await api.getPortfolioStatement(
      portfolioId,
      dateFrom: dateFrom?.toIso8601String().split('T').first,
      dateTo: dateTo?.toIso8601String().split('T').first,
    );
    final roiEntries = await api.getPortfolioRoi(portfolioId);
    final funds =
        await api.getFundEntries(portfolioId: portfolioId, status: 'Open');

    return _ReportsBundle(
      transactions: List<Map<String, dynamic>>.from(
          statement['transactions'] as List<dynamic>? ?? const []),
      roiEntries: roiEntries,
      funds: funds,
    );
  }
}

class _ReportsBundle {
  _ReportsBundle(
      {required this.transactions,
      required this.roiEntries,
      required this.funds});

  final List<Map<String, dynamic>> transactions;
  final List<RoiEntry> roiEntries;
  final List<FundEntryItem> funds;
}
