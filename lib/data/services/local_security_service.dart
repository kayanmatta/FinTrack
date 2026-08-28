import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/security_service.dart';

/// Armazena o hash do PIN nas preferências locais do dispositivo.
///
/// O PIN nunca é guardado em texto puro — apenas o hash SHA-256
/// com salt fixo do aplicativo.
class LocalSecurityService implements SecurityService {
  static const _pinKey = 'security.pin_hash';
  static const _salt = 'fintrack';

  String _hash(String pin) =>
      sha256.convert(utf8.encode('$_salt:$pin')).toString();

  @override
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  @override
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, _hash(pin));
  }

  @override
  Future<bool> validatePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) == _hash(pin);
  }
}
