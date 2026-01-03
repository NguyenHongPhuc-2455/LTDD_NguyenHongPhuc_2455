import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/role_management_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/admin_all_events_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHP Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(token: token),
          );
        } else if (settings.name == '/admin') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AdminScreen(
              token: args['token'],
              role: args['role'],
            ),
          );
        } else if (settings.name == '/role_management') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RoleManagementScreen(token: token),
          );
        } else if (settings.name == '/user_management') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => UserManagementScreen(token: token),
          );
        } else if (settings.name == '/admin_all_events') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AdminAllEventsScreen(token: token),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/add_event': (context) => AddEventScreen(),
        '/otp': (context) => OTPVerificationScreen(),
      },
    );
  }
}
