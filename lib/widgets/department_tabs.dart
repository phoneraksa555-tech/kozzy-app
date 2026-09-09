import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/shop_provider.dart';

class DepartmentTabs extends StatelessWidget {
  const DepartmentTabs({super.key});

  static const List<String> departments = [
    'MEN',
    'WOMEN',
    'BEAUTY',
    'LIFESTYLE',
    'KIDS',
  ];

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final active = shop.activeDepartment;

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppConstants.brandBorder, width: 0.8),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: departments.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dept = departments[index];
          final isSelected = dept == active;

          return GestureDetector(
            onTap: () => shop.setActiveDepartment(dept),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppConstants.brandBlack : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                dept,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: 0.5,
                  color: isSelected ? AppConstants.brandBlack : AppConstants.brandGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
