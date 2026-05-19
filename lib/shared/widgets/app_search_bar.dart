import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = "Buscar...",
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.caregiverPrimary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),

          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.caregiverPrimary,
          ),

          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();

                    if (onClear != null) {
                      onClear!();
                    }

                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                )
              : null,

          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
