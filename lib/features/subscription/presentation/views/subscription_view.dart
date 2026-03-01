import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/subscription/subscription_feature_flag_provider.dart';
import 'package:logit/features/subscription/presentation/providers/subscription_access_provider.dart';

class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureEnabled = ref.watch(subscriptionFeatureEnabledProvider);
    final state = ref.watch(subscriptionAccessNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF2F333D)
        : const Color(0xFFE3E0D5);
    final mutedTextColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72);

    if (!featureEnabled) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription')),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Subscription flow is disabled for this build.'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('LogIt Subscription')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B1F27), Color(0xFF13161D)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF8EA), Color(0xFFF5EFD9)],
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).cardColor.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.isSubscribed
                              ? 'You are on Pro plan'
                              : 'Choose your plan',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'LogIt Pro - Rs ${SubscriptionPlanLimits.monthlyPriceInr}/month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Free plan stays available with limits. You can upgrade anytime.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: mutedTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PlanComparisonTable(borderColor: borderColor),
            const SizedBox(height: 12),
            Text(
              'These limits are already enforced in task creation and reminder flow.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: mutedTextColor),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: _BottomPlanActions(
          isSubscribed: state.isSubscribed,
          onSelectFree: () async {
            if (state.isSubscribed) {
              await ref
                  .read(subscriptionAccessNotifierProvider.notifier)
                  .setSubscribed(false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reverted to free plan (temporary)'),
                  ),
                );
              }
              return;
            }
            ref
                .read(subscriptionAccessNotifierProvider.notifier)
                .markGateSeen();
            _exitToApp(context);
          },
          onSelectPro: () async {
            if (!state.isSubscribed) {
              await ref
                  .read(subscriptionAccessNotifierProvider.notifier)
                  .setSubscribed(true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro enabled (temporary)')),
                );
              }
            }
            if (!context.mounted) {
              return;
            }
            ref
                .read(subscriptionAccessNotifierProvider.notifier)
                .markGateSeen();
            _exitToApp(context);
          },
        ),
      ),
    );
  }

  void _exitToApp(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(RoutePaths.tasks);
  }
}

class _BottomPlanActions extends StatelessWidget {
  final bool isSubscribed;
  final Future<void> Function() onSelectFree;
  final Future<void> Function() onSelectPro;

  const _BottomPlanActions({
    required this.isSubscribed,
    required this.onSelectFree,
    required this.onSelectPro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: onSelectFree,
              child: Text(
                isSubscribed ? 'Use Free' : 'Continue Free',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: onSelectPro,
              child: Text(
                isSubscribed ? 'Keep Pro' : 'Go Pro',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanComparisonTable extends StatelessWidget {
  final Color borderColor;

  const _PlanComparisonTable({required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final rows = const <_FeatureRowData>[
      _FeatureRowData('Tasks per day', 'Up to 3', 'Unlimited'),
      _FeatureRowData('Subtasks per task', 'Up to 2', 'Unlimited'),
      _FeatureRowData('Reminders per task', '1', 'Unlimited'),
      _FeatureRowData('Repeat reminders', 'No', 'Yes'),
      _FeatureRowData('Task repeat', 'No', 'Yes'),
      _FeatureRowData('Max end-date range', '3 days', 'Flexible'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const _ComparisonHeader(),
          Divider(height: 1, thickness: 1, color: borderColor),
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return Column(
              children: [
                _ComparisonRow(data: entry.value),
                if (!isLast)
                  Divider(height: 1, thickness: 1, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Feature',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Free',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Pro',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final _FeatureRowData data;

  const _ComparisonRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final mutedTextColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.78);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              data.feature,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: mutedTextColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.freeValue,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.proValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRowData {
  final String feature;
  final String freeValue;
  final String proValue;

  const _FeatureRowData(this.feature, this.freeValue, this.proValue);
}
