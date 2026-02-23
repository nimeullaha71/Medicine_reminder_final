import 'package:flutter/material.dart';
import '../../../../common/app_shell.dart';
import '../../../chat/widget/custom_notification.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await NotificationService.getNotifications();
      setState(() {
        notifications = response.notifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int index) async {
    final notification = notifications[index];
    if (notification.isRead) return;

    // Optimistically update local state
    setState(() {
      notifications[index] = NotificationModel(
        id: notification.id,
        notificationType: notification.notificationType,
        title: notification.title,
        body: notification.body,
        isSent: notification.isSent,
        isRead: true,
        sentAt: notification.sentAt,
        medicine: notification.medicine,
      );
    });

    try {
      final success = await NotificationService.markAsRead(notification.id);
      if (!success) {
        // Rollback on failure (optional, but good practice)
        // For simplicity here, we'll just keep the optimistic update unless it's critical
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  Future<void> _deleteNotification(int index) async {
    final notification = notifications[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true; // Show loading while deleting or just remove instantly
      });

      try {
        final success = await NotificationService.deleteNotification(notification.id);
        if (success) {
          setState(() {
            notifications.removeAt(index);
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification deleted')),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete notification')),
            );
          }
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error deleting notification: $e');
      }
    }
  }

  String _getIconPath(String type) {
    switch (type) {
      case 'medicine_reminder':
        return 'assets/time.svg';
      case 'medical_test_alert':
        return 'assets/light.svg';
      case 'refill_alert':
        return 'assets/not.svg';
      default:
        return 'assets/cap.svg';
    }
  }
  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      parentTabIndex: 0,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xffE0712D),
            size: 18,
          ),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xffE0712D)))
            : error != null
                ? Center(child: Text(error!))
                : notifications.isEmpty
                    ? const Center(child: Text("No notifications yet"))
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomNotification(
                                title: notification.title,
                                message: notification.body,
                                time: _formatTime(notification.sentAt),
                                iconPath: _getIconPath(notification.notificationType),
                                isRead: notification.isRead,
                                onTap: () => _markAsRead(index),
                                onLongPress: () => _deleteNotification(index),
                              ),
                            );
                          },
                        ),
                      ),
    );
  }
}
