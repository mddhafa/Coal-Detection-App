import 'package:coalmobile_app/core/appbarcustom.dart';
import 'package:coalmobile_app/presentation/kelola%20user/adduser_screen.dart';
import 'package:coalmobile_app/presentation/kelola%20user/bloc/kelola_user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  @override
  void initState() {
    super.initState();
    context.read<KelolaUserBloc>().add(GetKelolaUserList());
  }

  Future<void> _refresh() async {
    context.read<KelolaUserBloc>().add(GetKelolaUserList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Kelola User"),
      body: BlocBuilder<KelolaUserBloc, KelolaUserState>(
        builder: (context, state) {
          if (state is KelolaUserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KelolaUserFailure) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 300),
                  Center(child: Text(state.error)),
                ],
              ),
            );
          }

          if (state is KelolaUserLoaded) {
            final users = state.data;

            if (users.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 300),
                    Center(child: Text("Data user kosong")),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Email: ${user.email}"),
                          Text("Phone: ${user.phone}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddUserPage(
                                        id: user.id.toString(),
                                        name: user.name,
                                        email: user.email,
                                        phone: user.phone,
                                      ),
                                ),
                              );

                              context.read<KelolaUserBloc>().add(
                                GetKelolaUserList(),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Hapus User"),
                                      content: Text(
                                        "Yakin hapus ${user.name}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Color(0xFF3A3A3A),
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF3A3A3A),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text("Hapus"),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                context.read<KelolaUserBloc>().add(
                                  DeleteKelolaUser(id: user.id.toString()),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserPage()),
          );

          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hapus User"),
            content: const Text("Apakah yakin ingin menghapus user ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // TODO: panggil delete API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User dihapus (dummy)")),
                  );
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
