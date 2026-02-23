import 'package:logit/core/widgets/custom_text_field.dart';
import 'package:logit/core/widgets/primary_button.dart';
import 'package:logit/features/auth/domain/usecases/set_pin_usecase/set_pin_usecase.dart';
import 'package:logit/features/auth/domain/usecases/verify_pin_usecase/verify_pin_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChangePinView extends ConsumerStatefulWidget {
  const ChangePinView({super.key});

  @override
  ConsumerState<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends ConsumerState<ChangePinView> {
  static final _pinPattern = RegExp(r'^\d{4}$');
  static final _pinInputFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ];

  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmNewPinController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmNewPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmNewPin = _confirmNewPinController.text.trim();

    String? validationError;
    if (!_pinPattern.hasMatch(currentPin) ||
        !_pinPattern.hasMatch(newPin) ||
        !_pinPattern.hasMatch(confirmNewPin)) {
      validationError = 'PIN must be exactly 4 digits';
    } else if (newPin != confirmNewPin) {
      validationError = 'New PIN and confirmation do not match';
    } else if (currentPin == newPin) {
      validationError = 'New PIN must be different from current PIN';
    }

    if (validationError != null) {
      setState(() {
        _errorText = validationError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final verifyResult = await ref
        .read(verifyPinUseCaseProvider)
        .call(VerifyPinParams(pin: currentPin));

    var verifyErrorMessage = '';
    var isCurrentPinValid = false;
    verifyResult.when(
      success: (isValid) {
        isCurrentPinValid = isValid;
      },
      failure: (failure) {
        verifyErrorMessage = failure.message;
      },
    );

    if (!mounted) {
      return;
    }

    if (!isCurrentPinValid) {
      setState(() {
        _isSubmitting = false;
        _errorText = verifyErrorMessage.isEmpty
            ? 'Current PIN is incorrect'
            : verifyErrorMessage;
      });
      return;
    }

    final setResult = await ref
        .read(setPinUseCaseProvider)
        .call(SetPinParams(pin: newPin));

    var updateErrorMessage = '';
    var isPinUpdated = false;
    setResult.when(
      success: (_) {
        isPinUpdated = true;
      },
      failure: (failure) {
        updateErrorMessage = failure.message;
      },
    );

    if (!mounted) {
      return;
    }

    if (!isPinUpdated) {
      setState(() {
        _isSubmitting = false;
        _errorText = updateErrorMessage.isEmpty
            ? 'Unable to update PIN'
            : updateErrorMessage;
      });
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final helperTextColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change PIN',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AbsorbPointer(
            absorbing: _isSubmitting,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update your 4-digit PIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your current PIN, then set a new one.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: helperTextColor),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  label: 'Current PIN',
                  hint: 'Enter current PIN',
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  controller: _currentPinController,
                  textInputAction: TextInputAction.next,
                  inputFormatters: _pinInputFormatters,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'New PIN',
                  hint: 'Enter new PIN',
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  controller: _newPinController,
                  textInputAction: TextInputAction.next,
                  inputFormatters: _pinInputFormatters,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  label: 'Confirm New PIN',
                  hint: 'Re-enter new PIN',
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  controller: _confirmNewPinController,
                  textInputAction: TextInputAction.done,
                  inputFormatters: _pinInputFormatters,
                  onSubmitted: (_) => _submit(),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Update PIN',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
