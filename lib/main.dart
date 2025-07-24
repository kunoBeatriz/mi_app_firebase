import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MiApp());
}

class MiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthScreen());
  }
}

class AuthScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print("Error en login anónimo: $e");
    }
  }

  Future<String> _fetchApiMessage() async {
    final response = await http.get(Uri.parse('http://localhost:3000/saludo'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['mensaje'];
    } else {
      throw Exception('Error al cargar el mensaje');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase + API')),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Usuario: ${snapshot.data!.uid}'),
                  ElevatedButton(
                    onPressed: () async {
                      final mensaje = await _fetchApiMessage();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(mensaje)));
                    },
                    child: Text('Obtener mensaje API'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: ElevatedButton(
                onPressed: _signInAnonymously,
                child: Text('Login Anónimo'),
              ),
            );
          }
        },
      ),
    );
  }
}
