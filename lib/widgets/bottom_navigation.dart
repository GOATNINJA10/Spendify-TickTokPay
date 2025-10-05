import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/view/home/home_screen.dart';
import 'package:spendify/view/wallet/statistics_screen.dart';
import 'package:spendify/view/calendar/calendar_screen.dart';
import 'package:spendify/widgets/common_bottom_sheet.dart';

import '../utils/utils.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    CalendarScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _screens[currentIndex],
            if (currentIndex == 0) // Only show FAB on home page
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => const CommonBottomSheet(),
                      );
                    },
                    backgroundColor: Colors.indigo[50],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Icon(
                      Iconsax.add,
                      size: 36,
                      color: AppColor.darkCard,
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: _onNavTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.chart_square, size: 30),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.calendar, size: 30),
          label: 'Calendar',
        ),
      ],
      selectedLabelStyle: normalText(16, AppColor.primarySoft),
      unselectedLabelStyle: normalText(12, AppColor.secondarySoft),
      selectedItemColor: Colors.white,
      unselectedItemColor: AppColor.secondarySoft,
      backgroundColor: AppColor.darkBackground,
      elevation: 0,
    );
  }
}
