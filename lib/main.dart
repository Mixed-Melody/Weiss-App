import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/collection_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

/// The entry point for the Weiß Schwarz tracker application.
void main() async {
  // Ensure that platform bindings are initialized before we use them.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database service before running the app.  This will
  // register Hive adapters and open the necessary boxes.
  await DatabaseService.instance.init();

  runApp(const MyApp());
}

/// Root widget that sets up providers and global theme.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionProvider()..reloadAll(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weiß Schwarz Tracker',

        // ← Dark theme with strong accents
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.tealAccent, // “+ / –” & FAB color
            secondary: Colors.orangeAccent, // Wishlist heart color
          ),
          iconTheme: const IconThemeData(color: Colors.tealAccent),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF121212),
            selectedItemColor: Colors.tealAccent,
            unselectedItemColor: Colors.grey,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
            ),
          ),
        ),
        themeMode: ThemeMode.dark, // always dark

        home: const HomeScreen(),
      ),
    );
  }
}
