import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({Key? key, required this.currentData})
    : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedAgeRange;
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedReligiousBelief;
  bool _isLoading = false;

  final List<Map<String, String>> _ageRanges = [
    {'value': '18-25', 'label': '18-25 años'},
    {'value': '26-35', 'label': '26-35 años'},
    {'value': '36-45', 'label': '36-45 años'},
    {'value': '46-55', 'label': '46-55 años'},
    {'value': '56+', 'label': '56+ años'},
  ];

  final List<Map<String, String>> _genders = [
    {'value': 'masculino', 'label': 'Masculino'},
    {'value': 'femenino', 'label': 'Femenino'},
    {'value': 'otro', 'label': 'Otro'},
    {'value': 'prefiero_no_decir', 'label': 'Prefiero no decir'},
  ];

  final List<Map<String, String>> _countries = [
    {'value': 'MX', 'label': 'México'},
    {'value': 'ES', 'label': 'España'},
    {'value': 'AR', 'label': 'Argentina'},
    {'value': 'CO', 'label': 'Colombia'},
    {'value': 'PE', 'label': 'Perú'},
    {'value': 'CL', 'label': 'Chile'},
    {'value': 'US', 'label': 'Estados Unidos'},
    {'value': 'OTRO', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _religiousBeliefs = [
    {'value': 'catolico', 'label': 'Católico'},
    {'value': 'cristiano', 'label': 'Cristiano'},
    {'value': 'evangelico', 'label': 'Evangélico'},
    {'value': 'ateo', 'label': 'Ateo'},
    {'value': 'agnostico', 'label': 'Agnóstico'},
    {'value': 'budista', 'label': 'Budista'},
    {'value': 'hindu', 'label': 'Hindú'},
    {'value': 'musulman', 'label': 'Musulmán'},
    {'value': 'otro', 'label': 'Otro'},
    {'value': 'ninguna', 'label': 'Ninguna'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAgeRange = widget.currentData['age_range'];
    _selectedGender = widget.currentData['gender'];
    _selectedCountry = widget.currentData['country'];
    _selectedReligiousBelief = widget.currentData['religious_belief'];
  }

  Future<void> _saveChanges() async {
    if (_selectedAgeRange == null ||
        _selectedGender == null ||
        _selectedCountry == null ||
        _selectedReligiousBelief == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.updateQuizInfo(
      ageRange: _selectedAgeRange!,
      gender: _selectedGender!,
      country: _selectedCountry!,
      religiousBelief: _selectedReligiousBelief!,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar true para recargar perfil
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Actualiza tu información básica',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Rango de edad
                  _buildDropdownField(
                    label: 'Rango de Edad',
                    value: _selectedAgeRange,
                    items: _ageRanges,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeRange = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Género
                  _buildDropdownField(
                    label: 'Género',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // País
                  _buildDropdownField(
                    label: 'País',
                    value: _selectedCountry,
                    items: _countries,
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Creencia religiosa
                  _buildDropdownField(
                    label: 'Creencia Religiosa',
                    value: _selectedReligiousBelief,
                    items: _religiousBeliefs,
                    onChanged: (value) {
                      setState(() {
                        _selectedReligiousBelief = value;
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // Botón de guardar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
