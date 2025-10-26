import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/event_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/event_list_page.dart';
import 'pages/add_event_page.dart';
import 'pages/media_page.dart';
import 'pages/all_events_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      // Provider untuk manajemen state event
      create: (context) => EventService(),
      child: const MyApp(),
    ),
  );
}

const Color spotifyGreen = Color(0xFF1DB954);
const Color spotifyBlack = Color(0xFF121212);
const Color spotifyCardBlack = Color(0xFF282828);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Event Planner',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: spotifyBlack,
        colorScheme: const ColorScheme.dark(
          primary: spotifyGreen,
          secondary: spotifyGreen,
          background: spotifyBlack,
          surface: spotifyCardBlack,
          onPrimary: Colors.black,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: spotifyBlack,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Controller penting untuk sinkron animasi halaman <-> BottomBar
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // Penting untuk mencegah memory leak
    _pageController.dispose();
    super.dispose();
  }

  // Daftar halaman utama aplikasi
  static const List<Widget> _pages = <Widget>[
    EventListPage(),
    AllEventsPage(),
    AddEventPage(),
    MediaPage(),
  ];

  void _onItemTapped(int index) {
    // Navigasi ke halaman berdasarkan BottomNav
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    // Update indikator BottomNav saat user swipe PageView
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Event Planner'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Daftar Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Tambah Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_media),
            label: 'Media',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: spotifyCardBlack,
        selectedItemColor: spotifyGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
