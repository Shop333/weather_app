import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = 'c3606858261aaad270807afed99959d3';

Future<void> main() async {
  stdout.write('Masukkan nama kota: ');
  String city = stdin.readLineSync()!;

  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=id'
  );

  final response = await http.get(url);
  final data = jsonDecode(response.body);

  print('\n📍 Kota: ${data['name']}');
  print('🌤️  Cuaca: ${data['weather'][0]['description']}');
  print('🌡️  Suhu: ${data['main']['temp']}°C');
  print('💧 Kelembaban: ${data['main']['humidity']}%');
  print('💨 Angin: ${data['wind']['speed']} m/s');
}