import 'package:flutter/material.dart';
import 'DashboardScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Task Manager',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.white,
      ),
      builder: (context, child) {
        return Stack(
          children: [
            // Background Image (Visible only on screens > 500px width)
            if (MediaQuery.of(context).size.width > 00)
              Positioned.fill(
                child: Image.asset(
                  'assets/images.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            
            // Constrained App Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: child,
              ),
            ),
          ],
        );
      },
      home: const DashboardScreen(),
    );
  }
}
