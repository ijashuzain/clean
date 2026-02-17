import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/theme/theme_mode_provider.dart';
import 'package:logit/features/auth/presentation/providers/auth_session_provider/auth_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
                  const _SectionTitle(text: 'Account'),
                  _SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentGold.withValues(
                                alpha: 0.28,
                              ),
                            ),
                            child: Text(
                              _initials(user.name, user.email),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.trim().isEmpty
                                      ? 'LogIt User'
                                      : user.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email.trim().isEmpty
                                      ? 'Signed in account'
                                      : user.email,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.72),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.accentGreen,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(text: 'Appearance'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _ThemeModeSelector(
                      selected: themeMode,
                      onChanged: (mode) => ref
                          .read(themeModeNotifierProvider.notifier)
                          .setMode(mode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle(text: 'App'),
                  _SurfaceCard(
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About LogIt',
                          onTap: () {
                            _showInfo(
                              context,
                              title: 'About LogIt',
                              message:
                                  'LogIt helps you plan daily tasks with subtasks, repeat schedules, and timeline tracking.',
                            );
                          },
                        ),
                        _divider(isDark),
                        _ActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy',
                          onTap: () {
                            _showInfo(
                              context,
                              title: 'Privacy',
                              message:
                                  'Local-first mode is active. Your tasks are currently stored on-device using Hive.',
                            );
                          },
                        ),
                        _divider(isDark),
                        _ActionTile(
                          icon: Icons.description_outlined,
                          title: 'Terms',
                          onTap: () {
                            _showInfo(
                              context,
                              title: 'Terms',
                              message:
                                  'When cloud sync is enabled, you can connect your own backend policies and terms.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC44949),
                        side: const BorderSide(color: Color(0xFFE9CACA)),
                        backgroundColor: const Color(0xFFFFFAFA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? 'v${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                    : 'v1.0.0';
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    'LogIt $version',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.2,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.62),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkBorder : const Color(0xFFE9E5D9),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Logout?'),
            content: const Text('You will need to log in again to continue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout || !context.mounted) {
      return;
    }

    await ref.read(authSessionNotifierProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }
    context.go(RoutePaths.login);
  }

  static void _showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _initials(String name, String email) {
    final cleanName = name.trim();
    if (cleanName.isNotEmpty) {
      final parts = cleanName.split(RegExp(r'\\s+'));
      if (parts.length == 1) {
        return parts.first.substring(0, 1).toUpperCase();
      }
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
          .toUpperCase();
    }

    final cleanEmail = email.trim();
    if (cleanEmail.isNotEmpty) {
      return cleanEmail.substring(0, 1).toUpperCase();
    }

    return 'U';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceAlt.withValues(alpha: 0.85)
              : const Color(0xFFF6F4EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeModeOption selected;
  final ValueChanged<ThemeModeOption> onChanged;

  const _ThemeModeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3E49) : const Color(0xFFE1DED3),
        ),
      ),
      child: Row(
        children: [
          _ThemeModeOptionButton(
            label: 'System',
            icon: Icons.phone_android_rounded,
            selected: selected == ThemeModeOption.system,
            onTap: () => onChanged(ThemeModeOption.system),
          ),
          const SizedBox(width: 4),
          _ThemeModeOptionButton(
            label: 'Light',
            icon: Icons.light_mode_rounded,
            selected: selected == ThemeModeOption.light,
            onTap: () => onChanged(ThemeModeOption.light),
          ),
          const SizedBox(width: 4),
          _ThemeModeOptionButton(
            label: 'Dark',
            icon: Icons.dark_mode_rounded,
            selected: selected == ThemeModeOption.dark,
            onTap: () => onChanged(ThemeModeOption.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeOptionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selected
                  ? (isDark
                        ? AppColors.accentGold.withValues(alpha: 0.24)
                        : AppColors.accentGold.withValues(alpha: 0.95))
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? (isDark
                          ? const Color(0xFF9E8A3D)
                          : const Color(0xFFD4BE4D))
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? (isDark ? AppColors.accentGold : AppColors.brandText)
                      : Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? (isDark ? AppColors.accentGold : AppColors.brandText)
                        : Theme.of(context).textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
