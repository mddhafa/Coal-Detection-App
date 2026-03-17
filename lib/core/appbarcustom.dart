import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 4,
      centerTitle: true,
      backgroundColor: Colors.transparent,

      // BACK BUTTON
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 20,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
              : null,

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1C1C1C), // coal black
              Color(0xFF3A3A3A), // dark grey
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),

      actions: actions,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
