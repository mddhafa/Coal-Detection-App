import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userRole; // 'admin' atau 'pegawai'

  const HomeScreen({super.key, required this.userRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _primaryRed = Color(0xFF932520);
  static const Color _primaryRedDark = Color(0xFF6E1B17);

  bool get isAdmin => widget.userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F2),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    const SizedBox(height: 28),
                    _buildLaporanSection(context),
                    if (isAdmin) ...[
                      const SizedBox(height: 28),
                      _buildAdminSection(context),
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

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: _primaryRed,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6E1B17), Color(0xFF932520), Color(0xFFB83030)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -20,
                child: _circle(150, Colors.white.withOpacity(0.06)),
              ),
              Positioned(
                bottom: -10,
                right: 60,
                child: _circle(80, Colors.white.withOpacity(0.05)),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.warehouse_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Coal Detection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings_outlined
                                      : Icons.person_outline,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isAdmin ? 'Admin' : 'Pegawai',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdmin ? 'Panel Admin' : 'Dashboard Gudang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => _showLogoutDialog(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Summary Cards ────────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    final cards =
        isAdmin
            ? [
              _SummaryData(
                label: 'Total Barang',
                value: '248',
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF2563EB),
              ),
              _SummaryData(
                label: 'Masuk Hari Ini',
                value: '12',
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF16A34A),
              ),
              _SummaryData(
                label: 'Keluar Hari Ini',
                value: '7',
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFFDC2626),
              ),
            ]
            : [
              _SummaryData(
                label: 'Tugas Aktif',
                value: '3',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF2563EB),
              ),
              _SummaryData(
                label: 'Selesai',
                value: '18',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16A34A),
              ),
            ];

    return Row(
      children:
          cards
              .map(
                (d) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: cards.indexOf(d) < cards.length - 1 ? 10 : 0,
                    ),
                    child: _SummaryCard(data: d),
                  ),
                ),
              )
              .toList(),
    );
  }

  // ── Laporan Section ──────────────────────────────────────────────────────────
  Widget _buildLaporanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Laporan'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _MenuCard(
              icon: Icons.bar_chart_rounded,
              label: 'Laporan\nHarian',
              color: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.calendar_month_outlined,
              label: 'Laporan\nBulanan',
              color: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.trending_up_rounded,
              label: 'Rekap\nBarang',
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFF0FDF4),
              onTap: () {},
            ),
            if (isAdmin)
              _MenuCard(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Export\nPDF',
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                onTap: () {},
              )
            else
              _MenuCard(
                icon: Icons.history_rounded,
                label: 'Riwayat\nAktivitas',
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }

  // ── Admin Only Section ───────────────────────────────────────────────────────
  Widget _buildAdminSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Manajemen (Admin)'),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _AdminMenuItem(
                icon: Icons.people_alt_outlined,
                label: 'Kelola Pengguna',
                subtitle: 'Tambah & atur akun pegawai',
                color: const Color(0xFF2563EB),
                onTap: () {},
                showDivider: true,
              ),
              _AdminMenuItem(
                icon: Icons.inventory_outlined,
                label: 'Kelola Barang',
                subtitle: 'Tambah & edit data barang',
                color: const Color(0xFF16A34A),
                onTap: () {},
                showDivider: true,
              ),
              _AdminMenuItem(
                icon: Icons.settings_outlined,
                label: 'Pengaturan',
                subtitle: 'Konfigurasi aplikasi',
                color: const Color(0xFF6B7280),
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Apakah kamu yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: panggil logout logic
                },
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

// ── Sub Widgets ───────────────────────────────────────────────────────────────

class _SummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _SummaryData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: data.color,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  const _AdminMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 18,
            endIndent: 18,
            color: Colors.grey[100],
          ),
      ],
    );
  }
}
