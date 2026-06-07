import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'sos_screen.dart';
import 'notification_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SOSScreen(),
    const NotificationScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Left & Right Navigation Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Tab
                InkWell(
                  onTap: () => _onTabTapped(0),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_filled,
                          color: _currentIndex == 0 ? const Color(0xFF00D5D5) : Colors.black38,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _currentIndex == 0 ? const Color(0xFF00D5D5) : Colors.black38,
                          ),
                        ),
                        // Underline indicator
                        if (_currentIndex == 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 12,
                            color: const Color(0xFF00D5D5),
                          ),
                      ],
                    ),
                  ),
                ),

                // Spacer for central floating button
                const SizedBox(width: 80),

                // Notification Tab
                InkWell(
                  onTap: () => _onTabTapped(2),
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_rounded,
                          color: _currentIndex == 2 ? const Color(0xFF00D5D5) : Colors.black38,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "notification",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _currentIndex == 2 ? const Color(0xFF00D5D5) : Colors.black38,
                          ),
                        ),
                        if (_currentIndex == 2)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 12,
                            color: const Color(0xFF00D5D5),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Central Floating SOS Button
            Positioned(
              top: -20,
              child: GestureDetector(
                onTap: () => _onTabTapped(1),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDD2476).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Center(
                    child: Text(
                      "sos",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
