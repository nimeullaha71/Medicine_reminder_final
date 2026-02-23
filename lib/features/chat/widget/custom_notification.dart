import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomNotification extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String iconPath;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CustomNotification({
    super.key,
    required this.title ,
    required this.message ,
    required this.time ,
    required this.iconPath ,
    this.isRead = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xffFFF0E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? const Color(0xffFFF0E6) : const Color(0xffE0712D).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: 45,
                      height: 45,
                    ),
                    if (!isRead)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xffE0712D),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
  
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xff333333),
                        fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
  
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xff333333),
                  fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
