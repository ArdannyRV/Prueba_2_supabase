import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _endpointUrl = 'https://login-flutter-lake.vercel.app/api/send-email';

  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String text,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpointUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error enviando correo: StatusCode ${response.statusCode} - Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción enviando correo: $e');
      return false;
    }
  }
}
