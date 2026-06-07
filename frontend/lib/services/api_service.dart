import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // 1. Health Check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'ok';
      }
    } catch (e) {
      print('Health check failed: $e');
    }
    return false;
  }

  // 2. Get App Permissions List
  static Future<List<Map<String, dynamic>>> getPermissions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/get-permissions/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['apps']);
      }
    } catch (e) {
      print('Get permissions failed: $e');
    }
    return [];
  }

  // 3. Get Social Privacy Tips
  static Future<List<String>> getSocialTips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/social-tips/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['tips']);
      }
    } catch (e) {
      print('Get social tips failed: $e');
    }
    return [];
  }

  // 4. Stalkerware Scanner Check
  static Future<Map<String, dynamic>> flagStalkerware() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/flag-stalkerware/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Flag stalkerware failed: $e');
    }
    return {
      "installed_apps": [],
      "stalkerware_detected": [],
      "message": "Error scanning for stalkerware."
    };
  }

  // 5. Generate Password
  static Future<String> generatePassword() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/generate-password/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['password'] ?? '';
      }
    } catch (e) {
      print('Generate password failed: $e');
    }
    return '';
  }

  // 6. Upload image to ImgBB and get reverse search link
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload/'));
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": "Failed to upload image. Server error code: ${response.statusCode}"};
      }
    } catch (e) {
      print('Upload image failed: $e');
      return {"error": e.toString()};
    }
  }

  // 7. Generate Takedown Request mailto content
  static Future<Map<String, dynamic>> generateTakedown({
    required String foundLink,
    String platformEmail = '',
    String customEmail = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/takedown/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'found_link': foundLink,
          'platform_email': platformEmail,
          'custom_email': customEmail,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": "Failed to generate takedown request."};
      }
    } catch (e) {
      print('Generate takedown failed: $e');
      return {"error": e.toString()};
    }
  }
}
