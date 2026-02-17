import 'package:logit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorStrip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final days = List<DateTime>.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final date = days[index];
          final selected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final dayKey = _dateKey(date);
          final emojis = (dayEmojiMap[dayKey] ?? const <String>[])
              .take(4)
              .toList();

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                onDateSelected(DateTime(date.year, date.month, date.day)),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 8.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkMutedText
                        : const Color(0xFFB8B9BC),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 52,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentGold
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBorder
                          : const Color(0xFFE6E4DD),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('d').format(date),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: selected ? AppColors.brandText : null,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (emojis.isNotEmpty) _buildEmojiCluster(emojis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dateKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  Widget _buildEmojiCluster(List<String> emojis) {
    const gap = SizedBox(width: 4);
    switch (emojis.length) {
      case 1:
        return _emojiCell(emojis[0]);
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_emojiCell(emojis[0]), gap, _emojiCell(emojis[1])],
        );
      case 3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_emojiCell(emojis[0]), gap, _emojiCell(emojis[1])],
            ),
            const SizedBox(height: 3),
            _emojiCell(emojis[2]),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_emojiCell(emojis[0]), gap, _emojiCell(emojis[1])],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_emojiCell(emojis[2]), gap, _emojiCell(emojis[3])],
            ),
          ],
        );
    }
  }

  Widget _emojiCell(String emoji) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 9)),
    );
  }
}
