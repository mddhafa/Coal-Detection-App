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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? "Tambah User" : "Edit User"),
      ),
      body: BlocListener<KelolaUserBloc, KelolaUserState>(
        listener: (context, state) {
          if (state is KelolaUserLoading) {
            setState(() => isLoading = true);
          } else {
            setState(() => isLoading = false);
          }

          if (state is KelolaUserSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }

          if (state is KelolaUserFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Nama wajib diisi" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "Email wajib diisi" : null,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "No HP",
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value!.isEmpty ? "No HP wajib diisi" : null,
                ),

                if (widget.id == null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password wajib diisi";
                      }
                      if (value.length < 6) {
                        return "Minimal 6 karakter";
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submit,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(widget.id == null ? "Simpan" : "Update"),
                  ),
                ),
              ],
            ),
          ),
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
