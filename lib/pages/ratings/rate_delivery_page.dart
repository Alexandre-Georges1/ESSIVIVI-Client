import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/rating.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';

class RateDeliveryPage extends StatefulWidget {
  final Order order;

  const RateDeliveryPage({super.key, required this.order});

  @override
  State<RateDeliveryPage> createState() => _RateDeliveryPageState();
}

class _RateDeliveryPageState extends State<RateDeliveryPage> {
  final _storageService = StorageService();
  final _authService = AuthService();
  final _commentController = TextEditingController();
  final _problemController = TextEditingController();

  int _rating = 0;
  bool _hasProblems = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une note')),
      );
      return;
    }

    final client = await _authService.getClient();
    if (client == null) return;

    setState(() => _isLoading = true);

    final rating = Rating(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: widget.order.id,
      clientId: client.id,
      stars: _rating,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
      problem: _hasProblems && _problemController.text.isNotEmpty
          ? _problemController.text
          : null,
      createdAt: DateTime.now(),
    );

    await _storageService.saveRating(rating);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre évaluation !')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluer la livraison'),
        backgroundColor: const Color(0xFF2C3E7D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order info
            Card(
              color: const Color(0xFF2C3E7D).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Commande #${widget.order.id.substring(widget.order.id.length - 6)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E7D),
                      ),
                    ),
                    if (widget.order.deliveryAgentName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Livrée par ${widget.order.deliveryAgentName}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Rating stars
            const Text(
              'Comment évaluez-vous cette livraison ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E7D),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _rating = starNumber);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      _rating >= starNumber ? Icons.star : Icons.star_border,
                      size: 48,
                      color: _rating >= starNumber
                          ? Colors.amber
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 16),
              Text(
                _getRatingText(_rating),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Comment
            const Text(
              'Commentaire (optionnel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E7D),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            // Problem checkbox
            CheckboxListTile(
              title: const Text('Signaler un problème'),
              value: _hasProblems,
              onChanged: (value) {
                setState(() => _hasProblems = value!);
              },
              activeColor: const Color(0xFF2C3E7D),
              contentPadding: EdgeInsets.zero,
            ),

            // Problem description
            if (_hasProblems) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _problemController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème rencontré...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.red.shade50,
                  prefixIcon: const Icon(Icons.warning, color: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRating,
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
                      'Envoyer l\'évaluation',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Très insatisfait';
      case 2:
        return 'Insatisfait';
      case 3:
        return 'Satisfaisant';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
