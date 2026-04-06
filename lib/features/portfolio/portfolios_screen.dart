import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/models/portfolio_item.dart';
import '../../shared/widgets/app_card.dart';
import '../client/client_api.dart';
import 'portfolio_detail_screen.dart';

class PortfoliosScreen extends StatelessWidget {
  const PortfoliosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<PortfolioItem>>(
        future: context.read<ClientApi>().getPortfolios(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final portfolios = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('My Portfolios', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Every portfolio linked to your client profile, with capital, ROI, payment date, and maturity visibility.'),
              const SizedBox(height: 20),
              ...portfolios.map((portfolio) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AppCard(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PortfolioDetailScreen(portfolio: portfolio))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(portfolio.portfolioNumber, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
                              Chip(label: Text(portfolio.status)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(portfolio.portfolioType),
                          const SizedBox(height: 14),
                          Text('Invested: ${AppFormatters.currency(portfolio.initialInvestment)}'),
                          Text('Current Capital: ${AppFormatters.currency(portfolio.currentCapital)}'),
                          Text('Total ROI: ${AppFormatters.currency(portfolio.totalRoi)}'),
                          Text('Maturity: ${AppFormatters.date(portfolio.maturityDate)}'),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
