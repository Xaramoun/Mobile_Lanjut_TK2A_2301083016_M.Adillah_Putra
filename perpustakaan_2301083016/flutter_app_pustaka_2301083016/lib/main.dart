import 'package:flutter/material.dart';
import 'screens/buku_list_screen.dart';
import 'screens/anggota_screen.dart';
import 'screens/peminjaman_screen.dart';
import 'screens/pengembalian_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pustaka App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/pengembalian': (context) => PengembalianScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _screens = [
    BukuListScreen(),
    AnggotaScreen(),
    PeminjamanScreen(),
    PengembalianScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Buku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Anggota',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color.fromARGB(255, 236, 11, 11),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}