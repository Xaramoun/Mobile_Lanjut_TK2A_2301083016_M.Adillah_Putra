import 'package:flutter/material.dart';
import 'screens/anggota_screen.dart';
import 'screens/buku_screen.dart';
import 'screens/peminjaman_screen.dart';
import 'screens/pengembalian_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AnggotaScreen(),
      BukuScreen(),
      PeminjamanScreen(),
      PengembalianScreen(),
      ProfileScreen(userData: widget.userData),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Anggota',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Buku',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward),
              label: 'Peminjaman',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_downward),
              label: 'Pengembalian',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}