import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _deliveryAddress;
  bool _useRegisteredAddress = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadAddress() async {
    final client = await _authService.getClient();
    if (client != null) {
      setState(() {
        _deliveryAddress = client.address;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final client = await _authService.getClient();
    if (client == null) return;

    setState(() => _isLoading = true);

    final preferredDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: client.id,
      quantity: int.parse(_quantityController.text),
      preferredDeliveryDate: preferredDateTime,
      deliveryAddress: _deliveryAddress!,
      specialInstructions: _instructionsController.text.isNotEmpty
          ? _instructionsController.text
          : null,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    await _storageService.saveOrder(order);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande créée avec succès')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Commande'),
        backgroundColor: const Color(0xFF2C3E7D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité souhaitée',
                  prefixIcon: Icon(Icons.shopping_cart),
                  suffixText: 'unités',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Champ requis';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Quantité invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date and time
              const Text(
                'Date et heure de livraison préférée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E7D),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: _selectDate,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2C3E7D),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: _selectTime,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF2C3E7D),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Delivery address
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E7D),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _useRegisteredAddress,
                            onChanged: (value) {
                              setState(() => _useRegisteredAddress = value!);
                            },
                          ),
                          const Expanded(
                            child: Text('Utiliser l\'adresse enregistrée'),
                          ),
                        ],
                      ),
                      if (_useRegisteredAddress && _deliveryAddress != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            _deliveryAddress!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Special instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Instructions spéciales (optionnel)',
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Ex: Livraison à l\'arrière du magasin',
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E7D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Valider la commande',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
