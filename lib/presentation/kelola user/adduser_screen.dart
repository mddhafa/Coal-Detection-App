import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:coalmobile_app/data/model/request/kelolauser_request_model.dart';
import 'package:coalmobile_app/presentation/kelola%20user/bloc/kelola_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddUserPage extends StatefulWidget {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;

  const AddUserPage({super.key, this.id, this.name, this.email, this.phone});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  static const Color _primaryColor = Color(0xFF3A3A3A);

  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      _nameController.text = widget.name ?? "";
      _emailController.text = widget.email ?? "";
      _phoneController.text = widget.phone ?? "";
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final request = KelolaUserRequestModel(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (widget.id == null) {
      context.read<KelolaUserBloc>().add(
        AddKelolaUser(kelolauserrequest: request),
      );
    } else {
      context.read<KelolaUserBloc>().add(
        UpdateKelolaUser(id: widget.id!, kelolauserrequest: request),
      );
    }
  }

  void showSnack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.id == null ? "Tambah User" : "Edit User",
      ),

      body: BlocListener<KelolaUserBloc, KelolaUserState>(
        listener: (context, state) {
          if (state is KelolaUserLoading) {
            setState(() => isLoading = true);
          } else {
            setState(() => isLoading = false);
          }

          if (state is KelolaUserSuccess) {
            showSnack(state.message, Colors.green, Icons.check_circle);
            Navigator.pop(context);
          }

          if (state is KelolaUserFailure) {
            showSnack(state.error, Colors.red, Icons.error);
          }
        },

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  widget.id == null
                      ? "Tambahkan User Baru"
                      : "Perbarui Data User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Isi data dengan benar",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),

                /// CARD FORM
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        controller: _nameController,
                        label: "Nama",
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _phoneController,
                        label: "No HP",
                        icon: Icons.phone,
                      ),

                      if (widget.id == null) ...[
                        const SizedBox(height: 16),

                        _buildField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    widget.id == null ? "Simpan" : "Update",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          (value) =>
              value == null || value.isEmpty ? "$label wajib diisi" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
