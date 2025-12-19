import 'package:flutter/material.dart';
import '../widgets/sweet_alert.dart';
import '../services/api_service.dart';
import 'quiz1_screen.dart';

class VerifyEmailCodeScreen extends StatefulWidget {
  final String email;
  final String userId;
  final String nombre;
  final String apellidos;
  final String password;

  const VerifyEmailCodeScreen({
    Key? key,
    required this.email,
    required this.userId,
    this.nombre = '',
    this.apellidos = '',
    this.password = '',
  }) : super(key: key);

  @override
  State<VerifyEmailCodeScreen> createState() => _VerifyEmailCodeScreenState();
}

class _VerifyEmailCodeScreenState extends State<VerifyEmailCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifying = false;
  bool _isCodeComplete = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en todos los campos
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_checkCodeComplete);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkCodeComplete() {
    bool allFilled = _controllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (_isCodeComplete != allFilled) {
      setState(() {
        _isCodeComplete = allFilled;
      });
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) return;

    setState(() {
      _isVerifying = true;
    });

    // Obtener el código completo
    String code = _controllers.map((c) => c.text).join();

    // Llamar a la API de verificación
    final result = await ApiService.verifyEmailCode(
      userId: widget.userId,
      code: code,
    );

    setState(() {
      _isVerifying = false;
    });

    if (result['success']) {
      // Verificación exitosa, obtener el token
      final responseData = result['data'];
      String? token;
      String userId = widget.userId;

      // El token puede venir en el nivel superior o dentro de 'data'
      if (responseData != null) {
        // Intentar obtener el token del nivel superior primero
        token = responseData['token']?.toString();

        // Obtener el userId de diferentes posibles ubicaciones
        if (responseData['data'] != null) {
          userId =
              responseData['data']['id']?.toString() ??
              responseData['data']['user_id']?.toString() ??
              widget.userId;
        } else {
          userId =
              responseData['user_id']?.toString() ??
              responseData['id']?.toString() ??
              responseData['userId']?.toString() ??
              widget.userId;
        }
      }

      // Si NO hay token en la respuesta, hacer login automático
      if (token == null || token.isEmpty) {
        if (widget.password.isNotEmpty) {
          final loginResult = await ApiService.login(
            email: widget.email,
            password: widget.password,
          );

          if (loginResult['success']) {
            // El login ya guarda los datos, solo navegar al Quiz1
          } else {
            // Guardar datos sin token
            await ApiService.saveUserData(
              token: '',
              userId: userId,
              nombre: widget.nombre,
              apellidos: widget.apellidos,
              email: widget.email,
            );
          }
        } else {
          // Sin password, solo guardar datos básicos
          await ApiService.saveUserData(
            token: '',
            userId: userId,
            nombre: widget.nombre,
            apellidos: widget.apellidos,
            email: widget.email,
          );
        }
      } else {
        // Si hay token, guardarlo directamente
        await ApiService.saveUserData(
          token: token,
          userId: userId,
          nombre: widget.nombre,
          apellidos: widget.apellidos,
          email: widget.email,
        );
      }

      // Navegar al Quiz1 para completar el perfil
      SweetAlert.showSuccess(
        context: context,
        title: 'Cuenta creada exitosamente',
        message: '"Has dado el primer paso hacia el dominio de ti mismo."',
        backgroundColor: const Color(0xFF102110),
      ).then((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Quiz1Screen()),
          (route) => false,
        );
      });
    } else {
      // Código inválido
      SweetAlert.showError(
        context: context,
        title: 'Código inválido',
        message: result['message'] ?? 'El código ingresado no es correcto',
      );
      // Limpiar campos
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _resendCode() {
    // TODO: Implementar reenvío de código si la API lo soporta
    SweetAlert.showInfo(
      context: context,
      title: 'Código reenviado',
      message: 'Hemos enviado un nuevo código a tu correo',
    );
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
              const Spacer(flex: 2),

              // Ícono de email
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade600],
                  ),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              const Text(
                'Revisa tu correo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                'Hemos enviado un código de\nverificación a:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // Campos para ingresar código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onCodeChanged(value, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Botón Verificar
              _isVerifying
                  ? const CircularProgressIndicator(color: Colors.orange)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCodeComplete ? _verifyCode : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Verificar código',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              // Reenviar código
              TextButton(
                onPressed: _resendCode,
                child: const Text(
                  '¿No recibiste el código? Reenviar',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
