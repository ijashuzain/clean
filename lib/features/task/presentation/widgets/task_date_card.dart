import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logit/core/theme/app_colors.dart';

@immutable
class TaskDateCardSizing {
  final double dayFontSize;
  final double dateFontSize;
  final double emojiCellSize;
  final double emojiFontSize;
  final double emojiGap;

  const TaskDateCardSizing({
    required this.dayFontSize,
    required this.dateFontSize,
    required this.emojiCellSize,
    required this.emojiFontSize,
    required this.emojiGap,
  });

  factory TaskDateCardSizing.fromCardWidth(double cardWidth) {
    return TaskDateCardSizing(
      dayFontSize: cardWidth < 36 ? 7.0 : 8.5,
      dateFontSize: cardWidth < 36
          ? 12.0
          : cardWidth < 42
          ? 14.0
          : 17.0,
      emojiCellSize: cardWidth < 36
          ? 7.5
          : cardWidth < 42
          ? 8.5
          : 9.5,
      emojiFontSize: cardWidth < 36
          ? 5.0
          : cardWidth < 42
          ? 5.8
          : 6.3,
      emojiGap: cardWidth < 42 ? 1.5 : 2.0,
    );
  }
}

class TaskDateCard extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final List<String> emojis;
  final double cardWidth;
  final double cardHeight;
  final TaskDateCardSizing sizing;
  final ValueChanged<DateTime>? onTap;
  final bool showDayLabel;
  final bool inCurrentMonth;

  const TaskDateCard({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.emojis,
    required this.cardWidth,
    required this.cardHeight,
    required this.sizing,
    this.onTap,
    this.showDayLabel = true,
    this.inCurrentMonth = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedDate = _dateOnly(date);
    final selected = _sameDate(normalizedDate, _dateOnly(selectedDate));
    final isToday = _sameDate(normalizedDate, _dateOnly(DateTime.now()));
    final displayEmojis = inCurrentMonth
        ? emojis.take(4).toList(growable: false)
        : const <String>[];

    final baseSurface = Theme.of(context).cardColor;
    final cardColor = selected
        ? AppColors.accentGold
        : inCurrentMonth
        ? baseSurface
        : baseSurface.withValues(alpha: 0.45);
    final cardBorder = selected
        ? Colors.transparent
        : isToday
        ? AppColors.accentGreen
        : Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorder
        : const Color(0xFFE6E4DD);
    final dateTextColor = selected
        ? AppColors.brandText
        : inCurrentMonth
        ? null
        : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.28);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDayLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(normalizedDate).toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                  fontSize: sizing.dayFontSize,
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
        ],
        Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder, width: isToday ? 1.2 : 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Text(
                DateFormat('d').format(normalizedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: sizing.dateFontSize,
                  color: dateTextColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 1),
              if (displayEmojis.isNotEmpty)
                SizedBox(
                  height: cardHeight * 0.32,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: _buildEmojiCluster(
                      displayEmojis,
                      cellSize: sizing.emojiCellSize,
                      cellFontSize: sizing.emojiFontSize,
                      cellGap: sizing.emojiGap,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) {
      return SizedBox(width: cardWidth, child: content);
    }

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap!(normalizedDate),
        child: content,
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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
