import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/notification_model.dart';
import '../../../../app/urls.dart';

class NotificationService {
  static final storage = GetStorage();
  
  static Future<NotificationResponse> getNotifications() async {
    final token = storage.read('access_token');
    print('Notification token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}');
    
    print('Sending notification request to: ${Urls.Notifications}');
    try {
      final response = await http.get(
        Uri.parse(Urls.Notifications),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 45));

      print('Notification API status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return NotificationResponse.fromJson(data);
      } else {
        print('Notification API Error Body: ${response.body}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Notification Service Exception: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  static Future<bool> markAsRead(int id) async {
    final token = storage.read('access_token');
    final url = Urls.markNotificationRead(id);
    print('Marking notification $id as read at: $url');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Mark as read API status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Mark as read API Error Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Mark as read error: $e');
      return false;
    }
  }

  static Future<bool> deleteNotification(int id) async {
    final token = storage.read('access_token');
    final url = Urls.deleteNotification(id);
    print('Deleting notification $id at: $url');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Delete notification API status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Delete notification API Error Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete notification error: $e');
      return false;
    }
  }
}
