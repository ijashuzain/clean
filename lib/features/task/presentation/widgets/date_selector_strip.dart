import 'package:flutter/material.dart';
import 'package:logit/features/task/presentation/widgets/task_date_card.dart';

class DateSelectorStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Map<String, List<String>> dayEmojiMap;

  const DateSelectorStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.dayEmojiMap,
  });

  @override
  State<DateSelectorStrip> createState() => _DateSelectorStripState();
}

class _DateSelectorStripState extends State<DateSelectorStrip> {
  static const int _initialPage = 5000;

  late final DateTime _anchorMonday;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _anchorMonday = _mondayOf(widget.selectedDate);
    _pageController = PageController(
      initialPage: _initialPage + _weekOffsetFromAnchor(widget.selectedDate),
    );
  }

  @override
  void didUpdateWidget(covariant DateSelectorStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetPage =
        _initialPage + _weekOffsetFromAnchor(widget.selectedDate);
    final currentPage = _pageController.hasClients
        ? _pageController.page?.round() ?? _pageController.initialPage
        : _pageController.initialPage;

    if (currentPage != targetPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(targetPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final cardWidth = (constraints.maxWidth - (spacing * 6)) / 7;
        final cardHeight = (cardWidth * 1.15).clamp(48.0, 62.0);
        final sizing = TaskDateCardSizing.fromCardWidth(cardWidth);
        final totalHeight = cardHeight + 21;

        return SizedBox(
          height: totalHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, page) {
              final monday = _anchorMonday.add(
                Duration(days: (page - _initialPage) * 7),
              );
              final days = List<DateTime>.generate(
                7,
                (index) => monday.add(Duration(days: index)),
              );

              return Row(
                children: [
                  for (var index = 0; index < days.length; index++) ...[
                    _buildDayCard(
                      date: days[index],
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      sizing: sizing,
                    ),
                    if (index != days.length - 1)
                      const SizedBox(width: spacing),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDayCard({
    required DateTime date,
    required double cardWidth,
    required double cardHeight,
    required TaskDateCardSizing sizing,
  }) {
    final dayKey = _dateKey(date);
    final emojis = widget.dayEmojiMap[dayKey] ?? const <String>[];

    return TaskDateCard(
      date: date,
      selectedDate: widget.selectedDate,
      emojis: emojis,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      sizing: sizing,
      onTap: widget.onDateSelected,
      showDayLabel: true,
      inCurrentMonth: true,
    );
  }

  void _handlePageChanged(int page) {
    final monday = _anchorMonday.add(Duration(days: (page - _initialPage) * 7));
    final weekdayOffset = widget.selectedDate.weekday - 1;
    final nextDate = monday.add(Duration(days: weekdayOffset));
    if (!_sameDate(nextDate, widget.selectedDate)) {
      widget.onDateSelected(nextDate);
    }
  }

  DateTime _mondayOf(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  int _weekOffsetFromAnchor(DateTime date) {
    final monday = _mondayOf(date);
    return monday.difference(_anchorMonday).inDays ~/ 7;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}
