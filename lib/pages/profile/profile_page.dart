import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/client.dart';
import '../../services/location_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _locationService = LocationService();

  Client? _client;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _storeNameController;
  late TextEditingController _responsibleController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _storeNameController = TextEditingController();
    _responsibleController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadClient();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _responsibleController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    final client = await _authService.getClient();
    if (client != null) {
      setState(() {
        _client = client;
        _nameController.text = client.name;
        _storeNameController.text = client.storeName ?? '';
        _responsibleController.text = client.responsibleName ?? '';
        _phoneController.text = client.phoneNumber;
        _addressController.text = client.address;
      });
    }
  }

  Future<void> _updateLocation() async {
    setState(() => _isLoading = true);
    final position = await _locationService.getCurrentLocation();

    if (position != null && _client != null) {
      final updatedClient = _client!.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _authService.saveClient(updatedClient);
      await _loadClient();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position GPS mise à jour')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedClient = _client!.copyWith(
      name: _nameController.text,
      storeName: _storeNameController.text.isNotEmpty
          ? _storeNameController.text
          : null,
      responsibleName: _responsibleController.text.isNotEmpty
          ? _responsibleController.text
          : null,
      address: _addressController.text,
    );

    await _authService.saveClient(updatedClient);
    await _loadClient();

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF2C3E7D),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _client == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile header
                    Card(
                      color: const Color(0xFF2C3E7D),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF2C3E7D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _client!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_client!.storeName != null)
                              Text(
                                _client!.storeName!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Information fields
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E7D),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _storeNameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Nom du point de vente',
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _responsibleController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Nom du responsable',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      enabled: _isEditing,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Adresse complète',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // GPS coordinates
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.gps_fixed,
                          color: Color(0xFF2C3E7D),
                        ),
                        title: const Text('Coordonnées GPS'),
                        subtitle: Text(
                          _client!.latitude != null &&
                                  _client!.longitude != null
                              ? 'Lat: ${_client!.latitude!.toStringAsFixed(6)}\nLng: ${_client!.longitude!.toStringAsFixed(6)}'
                              : 'Non enregistrées',
                        ),
                        trailing: IconButton(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          onPressed: _isLoading ? null : _updateLocation,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save/Cancel buttons
                    if (_isEditing) ...[
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
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
                            : const Text('Enregistrer les modifications'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          _loadClient();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2C3E7D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
