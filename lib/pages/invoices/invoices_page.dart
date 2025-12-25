import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final _storageService = StorageService();
  final _authService = AuthService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _period = 'all'; // all, day, week, month

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    final client = await _authService.getClient();
    if (client != null) {
      final allInvoices = await _storageService.getInvoices();
      final clientInvoices = allInvoices
          .where((invoice) => invoice.clientId == client.id)
          .toList();
      clientInvoices.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _invoices = clientInvoices;
        _isLoading = false;
      });
    }
  }

  List<Invoice> get _filteredInvoices {
    if (_period == 'all') return _invoices;

    final now = DateTime.now();
    DateTime startDate;

    switch (_period) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return _invoices;
    }

    return _invoices
        .where((invoice) => invoice.date.isAfter(startDate))
        .toList();
  }

  double get _totalAmount {
    return _filteredInvoices.fold(0, (sum, invoice) => sum + invoice.amount);
  }

  double get _totalDue {
    return _filteredInvoices
        .where((invoice) => !invoice.isPaid)
        .fold(0, (sum, invoice) => sum + invoice.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturation'),
        backgroundColor: const Color(0xFF2C3E7D),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary cards
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Period selector
                      Row(
                        children: [
                          Expanded(
                            child: _buildPeriodButton('Aujourd\'hui', 'day'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPeriodButton('Semaine', 'week'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPeriodButton('Mois', 'month')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildPeriodButton('Tout', 'all')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Amount cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmountCard(
                              'Total',
                              _totalAmount,
                              const Color(0xFF2C3E7D),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAmountCard(
                              'Montant dû',
                              _totalDue,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Invoices list
                Expanded(
                  child: _filteredInvoices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune facture trouvée',
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
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _showInvoiceDetails(invoice),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Facture #${invoice.id.substring(invoice.id.length - 6)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2C3E7D),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(invoice.date),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${invoice.amount.toStringAsFixed(2)} €',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2C3E7D),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: invoice.isPaid
                                                      ? Colors.green.withValues(
                                                          alpha: 0.2,
                                                        )
                                                      : Colors.orange
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  invoice.isPaid
                                                      ? 'Payée'
                                                      : 'Impayée',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: invoice.isPaid
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${invoice.items.length} livraison(s)',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
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

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _period == period;
    return ElevatedButton(
      onPressed: () {
        setState(() => _period = period);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFF2C3E7D)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildAmountCard(String label, double amount, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} €',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Détails de la facture',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E7D),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export PDF à venir')),
                          );
                        },
                        color: const Color(0xFF2C3E7D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('Numéro', '#${invoice.id}'),
                  _buildInfoRow(
                    'Date',
                    DateFormat('dd/MM/yyyy').format(invoice.date),
                  ),
                  _buildInfoRow('Statut', invoice.isPaid ? 'Payée' : 'Impayée'),
                  if (invoice.isPaid && invoice.paidAt != null)
                    _buildInfoRow(
                      'Date de paiement',
                      DateFormat('dd/MM/yyyy').format(invoice.paidAt!),
                    ),
                  const Divider(height: 32),
                  const Text(
                    'Livraisons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E7D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...invoice.items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(item.deliveryDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E7D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity} unités',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${item.unitPrice.toStringAsFixed(2)} € / unité',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${invoice.amount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E7D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
