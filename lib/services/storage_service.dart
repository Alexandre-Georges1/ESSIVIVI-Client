import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/invoice.dart';
import '../models/rating.dart';

class StorageService {
  static const String _keyOrders = 'orders';
  static const String _keyInvoices = 'invoices';
  static const String _keyRatings = 'ratings';

  // Orders
  Future<List<Order>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_keyOrders);

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        return decoded.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  Future<void> saveOrder(Order order) async {
    final orders = await getOrders();
    orders.add(order);
    await _saveOrders(orders);
  }

  Future<void> updateOrder(Order order) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      orders[index] = order;
      await _saveOrders(orders);
    }
  }

  Future<void> _saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = json.encode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_keyOrders, ordersJson);
  }

  // Invoices
  Future<List<Invoice>> getInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = prefs.getString(_keyInvoices);

      if (invoicesJson != null) {
        final List<dynamic> decoded = json.decode(invoicesJson);
        return decoded.map((item) => Invoice.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur lors de la récupération des factures: $e');
      return [];
    }
  }

  Future<void> saveInvoice(Invoice invoice) async {
    final invoices = await getInvoices();
    invoices.add(invoice);
    await _saveInvoices(invoices);
  }

  Future<void> _saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = json.encode(invoices.map((i) => i.toJson()).toList());
    await prefs.setString(_keyInvoices, invoicesJson);
  }

  // Ratings
  Future<List<Rating>> getRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = prefs.getString(_keyRatings);

      if (ratingsJson != null) {
        final List<dynamic> decoded = json.decode(ratingsJson);
        return decoded.map((item) => Rating.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur lors de la récupération des évaluations: $e');
      return [];
    }
  }

  Future<void> saveRating(Rating rating) async {
    final ratings = await getRatings();
    ratings.add(rating);
    await _saveRatings(ratings);
  }

  Future<void> _saveRatings(List<Rating> ratings) async {
    final prefs = await SharedPreferences.getInstance();
    final ratingsJson = json.encode(ratings.map((r) => r.toJson()).toList());
    await prefs.setString(_keyRatings, ratingsJson);
  }
}
