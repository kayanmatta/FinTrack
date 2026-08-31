import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';

/// Tela de bloqueio do aplicativo.
///
/// No primeiro acesso o usuário cria um PIN de 4 dígitos;
/// depois, o desbloqueio é por biometria (quando disponível) ou PIN.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const int _pinLength = 4;

  bool _loading = true;
  bool _hasPin = false;
  bool _biometric = false;
  bool _confirming = false;
  String _firstEntry = '';
  String _pin = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasPin = await ref.read(securityServiceProvider).hasPin();
    final biometric =
        await ref.read(authServiceProvider).isBiometricAvailable();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _biometric = biometric;
      _loading = false;
    });
  }

  String get _title {
    if (!_hasPin) return _confirming ? 'Confirmar PIN' : 'Criar PIN';
    return 'Bem-vindo de volta';
  }

  String get _subtitle {
    if (!_hasPin) {
      return _confirming
          ? 'Digite o mesmo PIN novamente'
          : 'Defina um PIN de 4 dígitos para proteger o app';
    }
    return 'Use a biometria ou digite seu PIN';
  }

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == _pinLength) _submit();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    final entered = _pin;
    if (!_hasPin) {
      if (!_confirming) {
        setState(() {
          _firstEntry = entered;
          _confirming = true;
          _pin = '';
        });
        return;
      }
      if (entered == _firstEntry) {
        await ref.read(securityServiceProvider).setPin(entered);
        _unlock();
      } else {
        setState(() {
          _confirming = false;
          _firstEntry = '';
          _pin = '';
          _error = 'Os PINs não conferem. Tente novamente.';
        });
      }
      return;
    }
    final ok = await ref.read(securityServiceProvider).validatePin(entered);
    if (ok) {
      _unlock();
    } else {
      setState(() {
        _pin = '';
        _error = 'PIN incorreto.';
      });
    }
  }

  Future<void> _onBiometric() async {
    final ok = await ref.read(authServiceProvider).authenticate(
          reason: 'Desbloqueie o Centivo para continuar.',
        );
    if (ok) {
      _unlock();
    } else if (mounted) {
      setState(() => _error = 'Biometria não reconhecida.');
    }
  }

  void _unlock() => ref.read(isUnlockedProvider.notifier).state = true;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(_title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_biometric && _hasPin) ...[
                    FilledButton.icon(
                      onPressed: _onBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Entrar com biometria'),
                    ),
                    const SizedBox(height: 24),
                  ],
                  _PinDots(length: _pinLength, filled: _pin.length),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.expense,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildKeypad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return SizedBox(
      width: 280,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        children: [
          for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
            _KeyButton(label: digit, onTap: () => _onDigit(digit)),
          const SizedBox.shrink(),
          _KeyButton(label: '0', onTap: () => _onDigit('0')),
          IconButton(
            onPressed: _onBackspace,
            icon: const Icon(Icons.backspace_outlined),
          ),
        ],
      ),
    );
  }
}

/// Botão numérico do teclado de PIN.
class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Indicador de dígitos digitados (bolinhas).
class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: i < filled ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }
}
