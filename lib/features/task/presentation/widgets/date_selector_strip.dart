import 'package:logit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        final dayFontSize = cardWidth < 36 ? 7.0 : 8.5;
        final dateFontSize = cardWidth < 36
            ? 12.0
            : cardWidth < 42
            ? 14.0
            : 17.0;
        final emojiCellSize = cardWidth < 36
            ? 9.0
            : cardWidth < 42
            ? 10.5
            : 12.0;
        final emojiFontSize = cardWidth < 36
            ? 6.0
            : cardWidth < 42
            ? 7.0
            : 8.0;
        final emojiGap = cardWidth < 42 ? 2.0 : 3.0;
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
                      context: context,
                      date: days[index],
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      dayFontSize: dayFontSize,
                      dateFontSize: dateFontSize,
                      emojiCellSize: emojiCellSize,
                      emojiFontSize: emojiFontSize,
                      emojiGap: emojiGap,
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
    required BuildContext context,
    required DateTime date,
    required double cardWidth,
    required double cardHeight,
    required double dayFontSize,
    required double dateFontSize,
    required double emojiCellSize,
    required double emojiFontSize,
    required double emojiGap,
  }) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selected =
        date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;
    final isToday = _sameDate(date, todayDate);
    final dayKey = _dateKey(date);
    final emojis = (widget.dayEmojiMap[dayKey] ?? const <String>[])
        .take(4)
        .toList();

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            widget.onDateSelected(DateTime(date.year, date.month, date.day)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                    fontSize: dayFontSize,
                    color: isToday
                        ? AppColors.accentGreen
                        : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkMutedText
                        : const Color(0xFFB8B9BC),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accentGold
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : isToday
                      ? AppColors.accentGreen
                      : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : const Color(0xFFE6E4DD),
                  width: isToday ? 1.2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: dateFontSize,
                      color: selected ? AppColors.brandText : null,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (emojis.isNotEmpty)
                    _buildEmojiCluster(
                      emojis,
                      cellSize: emojiCellSize,
                      cellFontSize: emojiFontSize,
                      cellGap: emojiGap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildEmojiCluster(
    List<String> emojis, {
    required double cellSize,
    required double cellFontSize,
    required double cellGap,
  }) {
    final gap = SizedBox(width: cellGap);
    switch (emojis.length) {
      case 1:
        return _emojiCell(
          emojis[0],
          cellSize: cellSize,
          cellFontSize: cellFontSize,
        );
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _emojiCell(
              emojis[0],
              cellSize: cellSize,
              cellFontSize: cellFontSize,
            ),
            gap,
            _emojiCell(
              emojis[1],
              cellSize: cellSize,
              cellFontSize: cellFontSize,
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _emojiCell(
                  emojis[0],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
                gap,
                _emojiCell(
                  emojis[1],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
              ],
            ),
            SizedBox(height: cellGap),
            _emojiCell(
              emojis[2],
              cellSize: cellSize,
              cellFontSize: cellFontSize,
            ),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _emojiCell(
                  emojis[0],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
                gap,
                _emojiCell(
                  emojis[1],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
              ],
            ),
            SizedBox(height: cellGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _emojiCell(
                  emojis[2],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
                gap,
                _emojiCell(
                  emojis[3],
                  cellSize: cellSize,
                  cellFontSize: cellFontSize,
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _emojiCell(
    String emoji, {
    required double cellSize,
    required double cellFontSize,
  }) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(cellSize * 0.36),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: cellFontSize)),
    );
  }
}
