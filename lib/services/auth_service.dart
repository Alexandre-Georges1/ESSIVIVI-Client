import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';

class AuthService {
  static const String _keyClient = 'client';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  Future<bool> register({
    required String phoneNumber,
    required String name,
    required String address,
    String? storeName,
    String? responsibleName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // TODO: Appel API réel pour inscription
      // Pour le moment, simulation locale
      final client = Client(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        name: name,
        address: address,
        storeName: storeName,
        responsibleName: responsibleName,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      await saveClient(client);
      return true;
    } catch (e) {
      debugPrint('Erreur d\'inscription: $e');
      return false;
    }
  }

  Future<bool> login(String phoneNumber, String pinCode) async {
    try {
      // Identifiants de test pour le développement
      // Numéro: 0600000000, PIN: 123456
      if (phoneNumber == '0600000000' && pinCode == '123456') {
        final testClient = Client(
          id: 'test_client_1',
          phoneNumber: phoneNumber,
          name: 'Client Test',
          storeName: 'Boutique Test',
          responsibleName: 'Responsable Test',
          address: '123 Rue de Test, 75000 Paris',
          latitude: 48.8566,
          longitude: 2.3522,
          pinCode: pinCode,
          createdAt: DateTime.now(),
        );
        await saveClient(testClient);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        return true;
      }

      // Vérification locale pour les autres comptes
      final prefs = await SharedPreferences.getInstance();
      final clientJson = prefs.getString(_keyClient);

      if (clientJson != null) {
        final client = Client.fromJson(json.decode(clientJson));
        if (client.phoneNumber == phoneNumber && client.pinCode == pinCode) {
          await prefs.setBool(_keyIsLoggedIn, true);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Erreur de connexion: $e');
      return false;
    }
  }

  Future<bool> setPinCode(String pinCode) async {
    try {
      final client = await getClient();
      if (client != null) {
        final updatedClient = client.copyWith(pinCode: pinCode);
        await saveClient(updatedClient);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la définition du code PIN: $e');
      return false;
    }
  }

  Future<void> saveClient(Client client) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClient, json.encode(client.toJson()));
  }

  Future<Client?> getClient() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientJson = prefs.getString(_keyClient);

      if (clientJson != null) {
        return Client.fromJson(json.decode(clientJson));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du client: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<bool> verifySMS(String code) async {
    // TODO: Implémenter la vérification SMS réelle
    // Pour le moment, accepter tout code à 6 chiffres
    return code.length == 6;
  }
}
