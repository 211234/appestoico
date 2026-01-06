import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../main.dart';
import 'package:country_picker/country_picker.dart';

class Quiz1Screen extends StatefulWidget {
  const Quiz1Screen({Key? key}) : super(key: key);

  @override
  State<Quiz1Screen> createState() => _Quiz1ScreenState();
}

class _Quiz1ScreenState extends State<Quiz1Screen> {
  String? selectedAge;
  String? selectedGender;
  String? selectedCountry;
  String? selectedCountryCode; // Para guardar el código del país

  final List<String> ageRanges = [
    '18-25',
    '26-35',
    '36-45',
    '46-55',
    '56-65',
    '65+',
  ];

  final List<String> genderOptions = ['Masculino', 'Femenino', 'Otro'];

  @override
  void initState() {
    super.initState();
    // Cargar datos guardados si existen
    final quiz = QuizService.currentQuiz;
    if (quiz.isQuiz1Complete()) {
      setState(() {
        selectedAge = quiz.ageRange;
        selectedGender = _getGenderDisplay(quiz.gender);
        selectedCountry = _getCountryDisplay(quiz.country);
        selectedCountryCode = quiz.country;
      });
    }
  }

  // Convertir valor del API a texto visual
  String _getGenderDisplay(String? gender) {
    if (gender == 'masculino') return 'Masculino';
    if (gender == 'femenino') return 'Femenino';
    if (gender == 'otro') return 'Otro';
    return gender ?? '';
  }

  String _getCountryDisplay(String? country) {
    if (country == 'mexico') return 'México';
    return country ?? '';
  }

  // Convertir texto visual a valor para el API
  String _getGenderValue(String display) {
    if (display == 'Masculino') return 'masculino';
    if (display == 'Femenino') return 'femenino';
    if (display == 'Otro') return 'otro';
    return display.toLowerCase();
  }

  Future<void> _continueToNext() async {
    if (selectedAge != null &&
        selectedGender != null &&
        selectedCountry != null) {
      // Guardar datos en el servicio con valores para el API
      await QuizService.updateQuiz1(
        ageRange: selectedAge!,
        gender: _getGenderValue(selectedGender!),
        country: selectedCountryCode ??
            selectedCountry ??
            'MX', // Usar código del país
      );

      // ✅ Navegar a HomePage (Quiz 1 completado)
      if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Indicador de progreso
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: const Text(
                  'Paso 1 de 5',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Ícono circular
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade600],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'Datos Personales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Cuéntanos un poco sobre ti',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pregunta de edad
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '¿Cuál es tu rango de edad?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Grid de edades
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                        children: ageRanges.map((age) {
                          final isSelected = selectedAge == age;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAge = age;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  age,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Pregunta de género
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '¿Con qué género te identificas?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Opciones de género
                      ...genderOptions.map((gender) {
                        final isSelected = selectedGender == gender;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGender = gender;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white24,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    gender,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (gender == 'Ver más')
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),

                      // Pregunta de país (opcional)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '¿En que pais vives? (Opcional)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Selector de país con country_picker
                      GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            countryListTheme: CountryListThemeData(
                              backgroundColor: Colors.black,
                              textStyle: const TextStyle(color: Colors.white),
                              searchTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              inputDecoration: InputDecoration(
                                hintText: 'Buscar país',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                            ),
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country.name;
                                selectedCountryCode = country.countryCode;
                              });
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 1),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCountry ?? 'Selecciona tu país',
                                style: TextStyle(
                                  color: selectedCountry != null
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Botón Continuar
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedAge != null && selectedGender != null
                          ? Colors.orange.shade400
                          : Colors.grey.shade600,
                      selectedAge != null && selectedGender != null
                          ? Colors.orange.shade600
                          : Colors.grey.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: selectedAge != null && selectedGender != null
                      ? _continueToNext
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
