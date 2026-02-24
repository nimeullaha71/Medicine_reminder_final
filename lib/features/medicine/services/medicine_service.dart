import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../app/urls.dart';
import '../models/medicine_model.dart';

class MedicineService {
  static final box = GetStorage();

  static Map<String, String> _getAuthHeaders() {
    final token = box.read('access_token');
    print(
      'Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}',
    );

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<List<MedicineModel>> fetchMedicines() async {
    try {
      final url = Urls.All_Medicine;
      
      print('🔍 Fetching medicines from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📊 Medicines API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          
          if (responseData.isEmpty) {
            print('📝 No medicines found in response');
            return [];
          }
          
          final medicines = responseData
              .map((item) => MedicineModel.fromJson(item as Map<String, dynamic>))
              .where((medicine) => medicine.id > 0 && medicine.name.isNotEmpty)
              .toList();
          
          print('✅ Successfully parsed ${medicines.length} medicines');
          return medicines;
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          throw Exception('Failed to parse medicines response: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('📝 No medicines found (404)');
        return [];
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load medicines: ${response.statusCode} - $errorMessage');
      }
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Network connection failed: ${e.message}');
    } on FormatException catch (e) {
      print('📝 Format error: $e');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print('💥 Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? 
             errorData['error'] ?? 
             errorData['detail'] ?? 
             'Unknown error';
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'No error details';
    }
  }

  static Future<bool> updateMedicineStock(int id, int stock) async {
    try {
      final url = Urls.updateMedicineStock(id);
      print('🚀 Updating medicine stock at: $url with amount: $stock');

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: jsonEncode({'stock': stock.toString()}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📊 Stock Update API Response status: ${response.statusCode}');
      print('📊 Stock Update API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Stock update error: $e');
      rethrow;
    }
  }

  static Future<int?> markMedicineTaken(int id) async {
    try {
      final url = Urls.markMedicineTaken(id);
      print('🚀 Marking medicine $id as taken at: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📊 Mark Taken API Response status: ${response.statusCode}');
      print('📊 Mark Taken API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['remaining_stock'] as int?;
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error marking medicine as taken: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createPrescription(Map<String, dynamic> prescriptionData) async {
    try {
      final url = Urls.Get_all_prescriptions;
      print('🚀 Creating prescription at: $url');
      print('📦 Payload: ${jsonEncode(prescriptionData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: jsonEncode(prescriptionData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📊 Prescription API Response status: ${response.statusCode}');
      print('📊 Prescription API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Prescription creation error: $e');
      rethrow;
    }
  }
}
