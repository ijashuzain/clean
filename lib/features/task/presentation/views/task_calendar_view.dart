import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/features/task/domain/usecases/get_emoji_preview_usecase/get_emoji_preview_usecase.dart';
import 'package:logit/features/task/presentation/providers/task_timeline_provider/task_timeline_provider.dart';
import 'package:logit/features/task/presentation/widgets/task_date_card.dart';

class TaskCalendarView extends ConsumerStatefulWidget {
  const TaskCalendarView({super.key});

  @override
  ConsumerState<TaskCalendarView> createState() => _TaskCalendarViewState();
}

class _TaskCalendarViewState extends ConsumerState<TaskCalendarView> {
  static const int _initialPage = 12000;

  late final DateTime _anchorMonth;
  late final PageController _pageController;
  late DateTime _selectedDate;

  final Map<String, List<String>> _dayEmojiMap = <String, List<String>>{};
  final Set<String> _loadedMonthKeys = <String>{};
  final Set<String> _loadingMonthKeys = <String>{};

  bool _loadingInitialMonths = true;

  @override
  void initState() {
    super.initState();
    final initialDate = _toDateOnly(
      ref.read(taskTimelineProviderProvider).selectedDate,
    );
    _selectedDate = initialDate;
    _anchorMonth = DateTime(initialDate.year, initialDate.month);
    _pageController = PageController(initialPage: _initialPage);
    Future.microtask(() => _prefetchAround(_anchorMonth));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final overlayBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (page) {
              final month = _monthForPage(page);
              _prefetchAround(month);
            },
            itemBuilder: (context, page) {
              final month = _monthForPage(page);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _MonthGrid(
                  month: month,
                  selectedDate: _selectedDate,
                  dayEmojiMap: _dayEmojiMap,
                  onDateTap: _onDateTap,
                ),
              );
            },
          ),
          if (_loadingMonthKeys.isNotEmpty || _loadingInitialMonths)
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: overlayBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onDateTap(DateTime date) async {
    final normalizedDate = _toDateOnly(date);
    setState(() => _selectedDate = normalizedDate);
    if (mounted) {
      context.pop(normalizedDate);
    }
  }

  Future<void> _prefetchAround(DateTime centerMonth) async {
    final months = <DateTime>[
      DateTime(centerMonth.year, centerMonth.month - 1),
      DateTime(centerMonth.year, centerMonth.month),
      DateTime(centerMonth.year, centerMonth.month + 1),
    ];
    await Future.wait(months.map(_loadMonth));
    if (!mounted) {
      return;
    }
    if (_loadingInitialMonths) {
      setState(() => _loadingInitialMonths = false);
    }
  }

  Future<void> _loadMonth(DateTime month) async {
    final monthKey = _monthKey(month);
    if (_loadedMonthKeys.contains(monthKey) ||
        _loadingMonthKeys.contains(monthKey)) {
      return;
    }

    if (mounted) {
      setState(() => _loadingMonthKeys.add(monthKey));
    } else {
      _loadingMonthKeys.add(monthKey);
    }

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final result = await ref
        .read(getEmojiPreviewUseCaseProvider)
        .call(EmojiPreviewParams(from: monthStart, to: monthEnd));

    result.when(
      success: (emojiMap) {
        _dayEmojiMap.addAll(emojiMap);
        _loadedMonthKeys.add(monthKey);
      },
      failure: (failure) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );

    _loadingMonthKeys.remove(monthKey);
    if (mounted) {
      setState(() {});
    }
  }

  DateTime _monthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(_anchorMonth.year, _anchorMonth.month + offset);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _monthKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$yyyy-$mm';
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final Map<String, List<String>> dayEmojiMap;
  final ValueChanged<DateTime> onDateTap;

  const _MonthGrid({
    required this.month,
    required this.selectedDate,
    required this.dayEmojiMap,
    required this.onDateTap,
  });

  static const List<String> _weekdayLabels = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? AppColors.darkMutedText.withValues(alpha: 0.75)
        : AppColors.lightMutedText.withValues(alpha: 0.72);
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );
    final days = List<DateTime>.generate(
      42,
      (index) => gridStart.add(Duration(days: index)),
      growable: false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalGap = 6.0;
        const verticalGap = 6.0;
        final cellWidth = (constraints.maxWidth - (horizontalGap * 6)) / 7;
        final cellHeight = (cellWidth * 1.15).clamp(50.0, 62.0);
        final sizing = TaskDateCardSizing.fromCardWidth(cellWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM').format(month),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 6),
            for (var row = 0; row < 6; row++) ...[
              Row(
                children: [
                  for (var col = 0; col < 7; col++) ...[
                    TaskDateCard(
                      date: days[row * 7 + col],
                      selectedDate: selectedDate,
                      emojis:
                          dayEmojiMap[_dateKey(days[row * 7 + col])] ??
                          const <String>[],
                      cardWidth: cellWidth,
                      cardHeight: cellHeight,
                      sizing: sizing,
                      onTap: onDateTap,
                      showDayLabel: false,
                      inCurrentMonth: days[row * 7 + col].month == month.month,
                    ),
                    if (col != 6) const SizedBox(width: horizontalGap),
                  ],
                ],
              ),
              if (row != 5) const SizedBox(height: verticalGap),
            ],
          ],
        );
      },
    );
  }

  static String _dateKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}
