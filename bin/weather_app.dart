import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = 'c3606858261aaad270807afed99959d3';
const historyFile = 'history.txt';

// Konversi Unix timestamp ke jam
String unixToTime(int unix) {
  final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true)
      .toLocal();
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// Simpan history
void saveHistory(String city) {
  final file = File(historyFile);
  List<String> history = [];
  if (file.existsSync()) {
    history = file.readAsLinesSync();
  }
  if (!history.contains(city)) {
    history.add(city);
    file.writeAsStringSync(history.join('\n'));
  }
}

// Tampilkan history
void showHistory() {
  final file = File(historyFile);
  if (!file.existsSync() || file.readAsStringSync().isEmpty) {
    print('Belum ada history pencarian.');
    return;
  }
  print('\n📋 History pencarian:');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    print('  ${i + 1}. ${lines[i]}');
  }
}

// Cuaca sekarang
Future<void> getWeather(String city) async {
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=id'
  );
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (data['cod'] != 200) {
    print('❌ Kota tidak ditemukan!');
    return;
  }

  saveHistory(city);

  final sunrise = unixToTime(data['sys']['sunrise']);
  final sunset = unixToTime(data['sys']['sunset']);

  print('\n📍 Kota: ${data['name']}');
  print('🌤️  Cuaca: ${data['weather'][0]['description']}');
  print('🌡️  Suhu: ${data['main']['temp']}°C');
  print('💧 Kelembaban: ${data['main']['humidity']}%');
  print('💨 Angin: ${data['wind']['speed']} m/s');
  print('🌅 Sunrise: $sunrise');
  print('🌇 Sunset: $sunset');

  await getForecast(city);
}

// Forecast 5 hari
Future<void> getForecast(String city) async {
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=id&cnt=5'
  );
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  print('\n📅 Forecast 5 Hari:');
  print('─────────────────────────────');
  for (var item in data['list']) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      item['dt'] * 1000, isUtc: true).toLocal();
    final tanggal = '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2,'0')}:00';
    final suhu = item['main']['temp'];
    final cuaca = item['weather'][0]['description'];
    print('📆 $tanggal | 🌡️ ${suhu}°C | $cuaca');
  }
  print('─────────────────────────────');
}

// Auto detect lokasi via IP
Future<String> detectCity() async {
  try {
    final response = await http.get(Uri.parse('http://ip-api.com/json'));
    final data = jsonDecode(response.body);
    return data['city'] ?? '';
  } catch (e) {
    return '';
  }
}

Future<void> main() async {
  print('╔════════════════════════╗');
  print('║    🌤️  Weather App      ║');
  print('╚════════════════════════╝');

  while (true) {
    print('\n1. Cari cuaca kota');
    print('2. Auto detect lokasi');
    print('3. Lihat history');
    print('4. Keluar');
    stdout.write('\nPilih menu: ');

    final pilihan = stdin.readLineSync();

    switch (pilihan) {
      case '1':
        stdout.write('Masukkan nama kota: ');
        final city = stdin.readLineSync()!;
        await getWeather(city);
        break;
      case '2':
        print('🔍 Mendeteksi lokasi...');
        final city = await detectCity();
        if (city.isEmpty) {
          print('❌ Gagal detect lokasi!');
        } else {
          print('📍 Lokasi terdeteksi: $city');
          await getWeather(city);
        }
        break;
      case '3':
        showHistory();
        break;
      case '4':
        print('👋 Sampai jumpa!');
        exit(0);
      default:
        print('❌ Pilihan tidak valid!');
    }
  }
}