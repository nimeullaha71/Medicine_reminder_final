import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../common/app_shell.dart';
import '../../../common/custom_medium.dart';
import '../../auth/ui/screen/signin_screen.dart';
import '../services/profile_services.dart';
import '../widget/custom_txt.dart';
import '../models/profile_model.dart';
import 'edit_screen.dart';

// Helper function to format time for UI display
String _formatTimeForUI(String? timeString) {
  if (timeString == null || timeString.isEmpty) {
    return 'Not provided';
  }
  
  try {
    // Parse 24-hour time and convert to 12-hour AM/PM
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    return DateFormat('h:mm a').format(parsedTime);
  } catch (e) {
    return timeString; // Return original if parsing fails
  }
}


class MyprofileScreen extends StatefulWidget {
  const MyprofileScreen({super.key});

  @override
  State<MyprofileScreen> createState() => _MyprofileScreenState();
}

class _MyprofileScreenState extends State<MyprofileScreen> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile when returning to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfile();
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.getProfile();

      // Only use local image if it belongs to current user
      final localImagePath = await ProfileService.getLocalImagePath();
      final isLocalImageValid = await ProfileService.isLocalImageForCurrentUser();

      ProfileModel updatedProfile = profile;
      if (localImagePath != null && isLocalImageValid) {
        updatedProfile = profile.copyWith(profilePicture: localImagePath);
        print('Using local profile image for current user: $localImagePath');
      } else {
        print('Local image not valid for current user, using API image');
        // Clear invalid local image
        if (localImagePath != null) {
          await ProfileService.saveLocalImagePath(null);
        }
      }

      setState(() {
        _profile = updatedProfile;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SubPageScaffold(
        parentTabIndex: 4,
        backgroundColor: const Color(0xFFFFFAF7),
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
            "My Profile",
            style: TextStyle(
              color: Color(0xffE0712D),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffE0712D)),
          ),
        ),
      );
    }

    if (_error != null) {
      return SubPageScaffold(
        parentTabIndex: 4,
        backgroundColor: const Color(0xFFFFFAF7),
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
            "My Profile",
            style: TextStyle(
              color: Color(0xffE0712D),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please login to access your profile',
                style: TextStyle(fontSize: 16, color: Colors.orange[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SigninScreen(),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE0712D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return SubPageScaffold(
      parentTabIndex: 4,
      backgroundColor: const Color(0xFFFFFAF7),
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
          "My Profile",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 293,
                width: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 170,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: _profile?.profilePicture != null
                                  ? Builder(
                                builder: (context) {
                                  if (_profile!.profilePicture!
                                      .startsWith('/data/') ||
                                      _profile!.profilePicture!
                                          .startsWith('file://')) {
                                    // Local file - use file path with cache-busting
                                    return Image.file(
                                      File(_profile!.profilePicture!),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      key: ValueKey('local_${_profile!.profilePicture}_${DateTime.now().millisecondsSinceEpoch}'),
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading local image: $error');
                                        return Icon(
                                          Icons.person,
                                          size: 150,
                                          color: Colors.grey[600],
                                        );
                                      },
                                    );
                                  } else {
                                    // Network image - use URL with cache-busting
                                    final cacheKey = ProfileService.getProfileImageCacheKey() ?? '';
                                    final imageUrl = _profile!.profilePicture!;
                                    final bustUrl = cacheKey.isNotEmpty 
                                        ? '$imageUrl?cache=$cacheKey'
                                        : imageUrl;
                                    
                                    return Image.network(
                                      bustUrl,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      key: ValueKey('network_$bustUrl'),
                                      headers: const {
                                        'Cache-Control': 'no-cache, no-store, must-revalidate',
                                        'Pragma': 'no-cache',
                                        'Expires': '0',
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading network image: $error');
                                        return Icon(
                                          Icons.person,
                                          size: 150,
                                          color: Colors.grey[600],
                                        );
                                      },
                                    );
                                  }
                                },
                              )
                                  : Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _profile?.fullName ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffE0712D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'assets/edi.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                              Color(0xffE0712D),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              CustomMedium(text: "Profile Info", onTap: () {}),
              SizedBox(height: 15),
              const SizedBox(height: 15),
              CustomTxt(
                title: "Full Name:",
                subtitle: _profile?.fullName ?? 'N/A',
              ),
              const SizedBox(height: 5),
              CustomTxt(title: "Email:", subtitle: _profile?.email ?? 'N/A'),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Address:",
                subtitle: _profile?.address ?? 'Not provided',
              ),

              SizedBox(height: 20),
              CustomMedium(text: "Other Info", onTap: () {}),

              const SizedBox(height: 15),
              CustomTxt(
                title: "Age:",
                subtitle: _profile?.age?.toString() ?? 'Not provided',
              ),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Health condition:",
                subtitle: _profile?.healthCondition ?? 'Not provided',
              ),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Wakeup time:",
                subtitle: _formatTimeForUI(_profile?.wakeupTime),
              ),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Breakfast time:",
                subtitle: _formatTimeForUI(_profile?.breakfastTime),
              ),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Lunch time:",
                subtitle: _formatTimeForUI(_profile?.lunchTime),
              ),
              const SizedBox(height: 5),
              CustomTxt(
                title: "Dinner time:",
                subtitle: _formatTimeForUI(_profile?.dinnerTime),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
