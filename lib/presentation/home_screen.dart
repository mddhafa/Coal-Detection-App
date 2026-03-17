import 'package:coalmobile_app/presentation/cctvcam_screen.dart';
import 'package:coalmobile_app/presentation/profile/profile_screen.dart';
import 'package:coalmobile_app/presentation/recaps_screen.dart';
import 'package:flutter/material.dart';
import 'package:coalmobile_app/presentation/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userRole;

  const HomeScreen({super.key, required this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get isAdmin => widget.userRole == 'admin';

  static const Color primaryRed = Color(0xFF932520);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _animController.forward();
  }

  /// REFRESH FUNCTION
  Future<void> _refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: FadeTransition(
        opacity: _fadeAnim,

        child: RefreshIndicator(
          onRefresh: _refreshPage,

          child: CustomScrollView(
            slivers: [
              _buildAppBar(),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 30),

                    _buildMenuSection(),

                    if (isAdmin) ...[
                      const SizedBox(height: 30),
                      _buildAdminSection(),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// APP BAR
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: (Color(0xFF3A3A3A)),
      automaticallyImplyLeading: false,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      "Coal Detection",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        /// PROFILE BUTTON
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },

                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Color(0xFF3A3A3A)),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// LOGOUT BUTTON
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Selamat Datang 👋",
                  style: TextStyle(color: Colors.white70),
                ),

                Text(
                  isAdmin ? "Panel Admin" : "Dashboard",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// MENU SECTION
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Fitur Utama",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,

          children: [
            _MenuCard(
              icon: Icons.videocam,
              label: "Monitoring\nReal-time",
              color: Colors.green,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CctvHlsScreen()),
                );
              },
            ),

            _MenuCard(
              icon: Icons.analytics,
              label: "Laporan",
              color: const Color.fromARGB(255, 65, 56, 82),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecapsMenuScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// ADMIN SECTION
  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Manajemen (Admin)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
            ],
          ),

          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.people),
                title: Text("Kelola Pengguna"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.inventory),
                title: Text("Kelola Barang"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Pengaturan"),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// LOGOUT DIALOG
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            title: const Text("Konfirmasi"),

            content: const Text("Apakah Anda yakin ingin keluar?"),

            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Color(0xFF3A3A3A)),
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A3A3A),
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },

                child: const Text("Keluar"),
              ),
            ],
          ),
    );
  }
}

/// MENU CARD
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Icon(icon, color: color, size: 28),

            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
