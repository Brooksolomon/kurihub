import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'check_in_screen.dart';
import 'reservations_screen.dart';
import 'find_staff_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({required this.camera, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resort App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.blue.shade900,
        primaryColor: Colors.blueAccent,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.lightBlueAccent,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: MainScreen(camera: camera),
    );
  }
}

class MainScreen extends StatefulWidget {
  final CameraDescription camera;
  const MainScreen({required this.camera, super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      CheckInScreen(camera: widget.camera),
      const ReservationsScreen(),
      const FindStaffScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: 'Check-In',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_online),
                  label: 'Reservations',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Find Staff',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
