import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
import 'package:logit/features/auth/presentation/providers/pin_auth_session_provider/pin_auth_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PinAuthView extends ConsumerStatefulWidget {
  const PinAuthView({super.key});

  @override
  ConsumerState<PinAuthView> createState() => _PinAuthViewState();
}

class _PinAuthViewState extends ConsumerState<PinAuthView> {
  String _enteredPin = '';
  String? _firstPinEntry;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pinAuthSessionNotifierProvider);
    final isBusy = state.actionStatus.isLoading;
    final isSetupMode = !state.hasPin;

    ref.listen(pinAuthSessionNotifierProvider, (previous, next) {
      final previousMessage = previous?.message ?? '';
      if (next.message.isEmpty || next.message == previousMessage) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(next.message)));
    });

    if (!state.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const BrandLogo(fontSize: 36),
              const SizedBox(height: 26),
              Text(
                _title(isSetupMode),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle(isSetupMode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PinIndicatorRow(length: _enteredPin.length),
              const SizedBox(height: 12),
              if (isSetupMode)
                Text(
                  _firstPinEntry == null
                      ? 'Create a new PIN'
                      : 'Confirm your PIN',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.72),
                  ),
                ),
              const Spacer(),
              _PinPad(
                enabled: !isBusy,
                onDigitTap: _onDigitTap,
                onBackspaceTap: _onBackspaceTap,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 22,
                child: _enteredPin.isNotEmpty
                    ? TextButton(
                        onPressed: isBusy ? null : _clearCurrentPin,
                        child: const Text('Clear'),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(bool isSetupMode) {
    if (!isSetupMode) {
      return 'Enter your PIN';
    }
    return _firstPinEntry == null ? 'Create 4-digit PIN' : 'Confirm your PIN';
  }

  String _subtitle(bool isSetupMode) {
    if (!isSetupMode) {
      return 'Unlock LogIt to continue';
    }
    return _firstPinEntry == null
        ? 'Set a secure 4-digit PIN for this device'
        : 'Re-enter the same PIN to finish setup';
  }

  void _onDigitTap(String digit) {
    final state = ref.read(pinAuthSessionNotifierProvider);
    if (state.actionStatus.isLoading || _enteredPin.length >= 4) {
      return;
    }
    setState(() {
      _enteredPin = '$_enteredPin$digit';
    });
    if (_enteredPin.length == 4) {
      _submitPin();
    }
  }

  void _onBackspaceTap() {
    final state = ref.read(pinAuthSessionNotifierProvider);
    if (state.actionStatus.isLoading || _enteredPin.isEmpty) {
      return;
    }
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _clearCurrentPin() {
    setState(() {
      _enteredPin = '';
    });
  }

  Future<void> _submitPin() async {
    final pin = _enteredPin;
    final state = ref.read(pinAuthSessionNotifierProvider);
    final notifier = ref.read(pinAuthSessionNotifierProvider.notifier);

    if (!state.hasPin) {
      if (_firstPinEntry == null) {
        setState(() {
          _firstPinEntry = pin;
          _enteredPin = '';
        });
        return;
      }

      if (_firstPinEntry != pin) {
        setState(() {
          _enteredPin = '';
          _firstPinEntry = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN does not match')));
        return;
      }

      final success = await notifier.registerPin(pin);
      if (!mounted) {
        return;
      }
      if (success) {
        context.go(RoutePaths.tasks);
        return;
      }
      setState(() {
        _enteredPin = '';
      });
      return;
    }

    final success = await notifier.unlockWithPin(pin);
    if (!mounted) {
      return;
    }
    if (success) {
      context.go(RoutePaths.tasks);
      return;
    }
    setState(() {
      _enteredPin = '';
    });
  }
}

class _PinIndicatorRow extends StatelessWidget {
  final int length;

  const _PinIndicatorRow({required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final filled = index < length;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.accentGold : Colors.transparent,
            border: Border.all(
              color: filled
                  ? AppColors.accentGold
                  : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              width: 1.4,
            ),
          ),
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;

  const _PinPad({
    required this.enabled,
    required this.onDigitTap,
    required this.onBackspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PinPadRow(
          values: const ['1', '2', '3'],
          enabled: enabled,
          onDigitTap: onDigitTap,
        ),
        _PinPadRow(
          values: const ['4', '5', '6'],
          enabled: enabled,
          onDigitTap: onDigitTap,
        ),
        _PinPadRow(
          values: const ['7', '8', '9'],
          enabled: enabled,
          onDigitTap: onDigitTap,
        ),
        Row(
          children: [
            const Expanded(child: SizedBox(height: 68)),
            Expanded(
              child: _PinKey(
                label: '0',
                enabled: enabled,
                onTap: () => onDigitTap('0'),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: enabled ? onBackspaceTap : null,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinPadRow extends StatelessWidget {
  final List<String> values;
  final bool enabled;
  final ValueChanged<String> onDigitTap;

  const _PinPadRow({
    required this.values,
    required this.enabled,
    required this.onDigitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values
          .map(
            (value) => Expanded(
              child: _PinKey(
                label: value,
                enabled: enabled,
                onTap: () => onDigitTap(value),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PinKey({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
