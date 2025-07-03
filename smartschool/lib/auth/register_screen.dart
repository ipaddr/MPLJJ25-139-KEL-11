import 'package:flutter/material.dart';
import 'package:smartschool/auth/auth_repository.dart';
import 'package:smartschool/utils/app_constants.dart';
import 'package:smartschool/utils/app_router.dart';
// ... imports ...
import 'package:smartschool/screens/widgets/custom_text_field.dart'; // Tambahkan ini

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // <<<--- Tambahkan ini
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _roles = ['siswa', 'guru', 'orangtua'];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // <<<--- Lakukan validasi form
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final user = await _authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          role: _selectedRole!,
        );

        if (user != null) {
          if (context.mounted) {
            _showSuccessSnackBar('Registrasi berhasil! Silakan login.');
            Navigator.pushReplacementNamed(context, AppRouter.authRoute);
          }
        } else {
          _showErrorSnackBar('Registrasi gagal: Terjadi masalah.');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        _showErrorSnackBar(_errorMessage!);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun SmartSchool'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            // <<<--- Bungkus dengan Form
            key: _formKey, // <<<--- Assign GlobalKey
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_smartschool.png', height: 100),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun Baru',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppConstants.primaryBlue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  // <<<--- Gunakan CustomTextField
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  // <<<--- Gunakan CustomTextField
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  // <<<--- Gunakan CustomTextField
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan password (min. 6 karakter)',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Peran Anda',
                    prefixIcon: Icon(
                      Icons.category,
                      color: AppConstants.primaryBlue[700],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: AppConstants.primaryBlue.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: AppConstants.accentBlue,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: AppConstants.primaryBlue.shade200,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                  ),
                  value: _selectedRole,
                  hint: const Text('Siswa, Guru, atau Orang Tua'),
                  items:
                      _roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role.replaceFirst(role[0], role[0].toUpperCase()),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Mohon pilih peran Anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Daftar Akun',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.authRoute,
                    );
                  },
                  child: Text(
                    'Sudah punya akun? Login di sini',
                    style: TextStyle(
                      color: AppConstants.primaryBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
