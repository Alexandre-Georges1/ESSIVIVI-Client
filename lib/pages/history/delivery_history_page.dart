import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../ratings/rate_delivery_page.dart';

class DeliveryHistoryPage extends StatefulWidget {
  const DeliveryHistoryPage({super.key});

  @override
  State<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  final _storageService = StorageService();
  final _authService = AuthService();
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  OrderStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final client = await _authService.getClient();
    if (client != null) {
      final allOrders = await _storageService.getOrders();
      final clientOrders = allOrders
          .where((order) => order.clientId == client.id)
          .toList();
      clientOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _orders = clientOrders;
        _filteredOrders = clientOrders;
        _isLoading = false;
      });
    }
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            order.id.contains(_searchQuery) ||
            order.deliveryAddress.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        final matchesStatus =
            _filterStatus == null || order.status == _filterStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.inDelivery:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Livraisons'),
        backgroundColor: const Color(0xFF2C3E7D),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export PDF à venir')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterOrders();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tous', null),
                      _buildFilterChip('En attente', OrderStatus.pending),
                      _buildFilterChip('Acceptée', OrderStatus.accepted),
                      _buildFilterChip('En livraison', OrderStatus.inDelivery),
                      _buildFilterChip('Livrée', OrderStatus.delivered),
                      _buildFilterChip('Annulée', OrderStatus.cancelled),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showOrderDetails(order),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Commande #${order.id.substring(order.id.length - 6)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C3E7D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy à HH:mm',
                                            ).format(order.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          order.status,
                                        ).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order.statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(order.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${order.quantity} unités'),
                                    const SizedBox(width: 16),
                                    if (order.amount != null) ...[
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${order.amount!.toStringAsFixed(2)} €',
                                      ),
                                    ],
                                  ],
                                ),
                                if (order.deliveryAgentName != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(order.deliveryAgentName!),
                                    ],
                                  ),
                                ],
                                if (order.status == OrderStatus.delivered) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                RateDeliveryPage(order: order),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.star, size: 18),
                                      label: const Text('Évaluer'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF2C3E7D,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = selected ? status : null;
            _filterOrders();
          });
        },
        selectedColor: const Color(0xFF2C3E7D).withValues(alpha: 0.2),
        checkmarkColor: const Color(0xFF2C3E7D),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Détails de la livraison',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E7D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    'Date de livraison',
                    order.deliveredAt != null
                        ? DateFormat(
                            'dd/MM/yyyy à HH:mm',
                          ).format(order.deliveredAt!)
                        : 'Non livrée',
                  ),
                  _buildInfoCard('Quantité', '${order.quantity} unités'),
                  if (order.amount != null)
                    _buildInfoCard(
                      'Montant',
                      '${order.amount!.toStringAsFixed(2)} €',
                    ),
                  if (order.deliveryAgentName != null)
                    _buildInfoCard(
                      'Agent commercial',
                      order.deliveryAgentName!,
                    ),
                  _buildInfoCard('Adresse', order.deliveryAddress),
                  if (order.deliveryLatitude != null &&
                      order.deliveryLongitude != null)
                    _buildInfoCard(
                      'Coordonnées GPS',
                      'Lat: ${order.deliveryLatitude!.toStringAsFixed(6)}\nLng: ${order.deliveryLongitude!.toStringAsFixed(6)}',
                    ),
                  if (order.specialInstructions != null)
                    _buildInfoCard('Instructions', order.specialInstructions!),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
