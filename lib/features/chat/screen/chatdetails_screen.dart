import 'package:care_agent/features/chat/models/chat_prescription_model.dart';
import 'package:care_agent/features/chat/screen/chats_screen.dart';
import 'package:care_agent/features/chat/widget/custom_linkwith.dart';
import 'package:care_agent/features/doctor/models/doctor_list_model.dart';
import 'package:care_agent/features/doctor/services/doctor_api_service.dart';
import 'package:flutter/material.dart';
import '../../../app/urls.dart';
import '../../../common/app_shell.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/widget/custom_bull.dart';
import '../../profile/widget/custom_details.dart';
import '../../profile/widget/custom_details1.dart';
import '../../profile/widget/custom_info.dart';
import '../widget/custom_minibutton.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../medicine/services/medicine_service.dart';

class ChatdetailsScreen extends StatefulWidget {
  final ChatPrescriptionModel? prescriptionData;
  const ChatdetailsScreen({super.key, this.prescriptionData});

  @override
  State<ChatdetailsScreen> createState() => _ChatdetailsScreenState();
}

class _ChatdetailsScreenState extends State<ChatdetailsScreen> {

  ChatPrescriptionModel? prescriptionData;
  bool isLoading = true;
  String? errorMessage;
  

  List<DoctorListModel> doctors = [];
  bool isLoadingDoctors = true;
  String? doctorError;


  List<String> selectedMeals = [];


  int? currentUserId;
  int? selectedDoctorId;
  final TextEditingController _nextAppointmentController = TextEditingController();
  Map<String, String> fieldErrors = {};

  @override
  void dispose() {
    _nextAppointmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService.currentUserId; // Use current user ID from AuthService
    
    if (widget.prescriptionData != null) {
      prescriptionData = widget.prescriptionData;
      isLoading = false;
      
      // Initialize selectedMeals and doctor for the passed data
      _initializeMeals(prescriptionData!);
      if (prescriptionData!.data.isNotEmpty && prescriptionData!.data.first.doctor != null) {
        selectedDoctorId = prescriptionData!.data.first.doctor;
      }
    } else {
      _fetchPrescriptionData();
    }
    _fetchDoctors();
  }

  void _initializeMeals(ChatPrescriptionModel model) {
    if (model.data.isEmpty) return;
    final firstData = model.data.first;
    selectedMeals = [];
    for (var med in firstData.medicines) {
      selectedMeals.add(med.morning?.afterMeal == true ? 'After Meal' : 'Before Meal');
      selectedMeals.add(med.afternoon?.afterMeal == true ? 'After Meal' : 'Before Meal');
      selectedMeals.add(med.evening?.afterMeal == true ? 'After Meal' : 'Before Meal');
      selectedMeals.add(med.night?.afterMeal == true ? 'After Meal' : 'Before Meal');
    }
  }

  Future<void> _handleSave() async {
    if (prescriptionData == null || prescriptionData!.data.isEmpty) return;
    
    setState(() => fieldErrors = {});
    final Map<String, String> errors = {};
    final firstData = prescriptionData!.data.first;

    // 1. Patient Validation
    if (firstData.patient?.name == null || firstData.patient!.name.isEmpty) {
      errors['patient_name'] = 'Patient name is required';
    }
    if (firstData.patient?.age == null) {
      errors['patient_age'] = 'Age is required';
    }
    if (firstData.patient?.sex == null || firstData.patient!.sex.isEmpty) {
      errors['patient_gender'] = 'Sex is required';
    }

    // 2. Doctor Validation
    if (selectedDoctorId == null) {
      errors['doctor'] = 'Please select a doctor';
    }

    // 3. Medicine Validation
    for (int i = 0; i < firstData.medicines.length; i++) {
      final med = firstData.medicines[i];
      if (med.name.isEmpty) {
        errors['med_name_$i'] = 'Medicine name is required';
      }
      if (med.howManyDay == null || med.howManyDay! <= 0) {
        errors['med_days_$i'] = 'Valid days required';
      }
      if (med.stock == null || med.stock! < 0) {
        errors['med_stock_$i'] = 'Valid stock required';
      }

      // Time slot validation
      void validateTime(MedicineTime? t, String slotName) {
        if (t != null) {
          if (t.time == null || t.time!.isEmpty || t.time == 'HH:MM AM/PM') {
            errors['med_${slotName}_$i'] = 'Time is required';
          }
        }
      }
      validateTime(med.morning, 'morning');
      validateTime(med.afternoon, 'afternoon');
      validateTime(med.evening, 'evening');
      validateTime(med.night, 'night');
    }

    if (errors.isNotEmpty) {
      setState(() => fieldErrors = errors);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      
      final payload = {
        "doctor": selectedDoctorId,
        "next_appointment_date": _nextAppointmentController.text.isNotEmpty 
            ? _nextAppointmentController.text 
            : firstData.nextAppointmentDate,
        "patient": {
          "name": firstData.patient?.name,
          "age": firstData.patient?.age,
          "sex": firstData.patient?.sex,
          "health_issues": firstData.patient?.healthIssues,
        },
        "medicines": firstData.medicines.map((m) {
          final Map<String, dynamic> medJson = {
            "name": m.name,
            "how_many_day": m.howManyDay,
            "stock": m.stock,
          };
          if (m.morning != null) medJson["morning"] = m.morning!.copyWith(time: _formatToHHmmss(m.morning!.time)).toJson();
          if (m.afternoon != null) medJson["afternoon"] = m.afternoon!.copyWith(time: _formatToHHmmss(m.afternoon!.time)).toJson();
          if (m.evening != null) medJson["evening"] = m.evening!.copyWith(time: _formatToHHmmss(m.evening!.time)).toJson();
          if (m.night != null) medJson["night"] = m.night!.copyWith(time: _formatToHHmmss(m.night!.time)).toJson();
          return medJson;
        }).toList(),
      };

      await MedicineService.createPrescription(payload);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved successfully!'), backgroundColor: Colors.green),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChatsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _fetchPrescriptionData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final box = GetStorage();
      final token = box.read('access_token');
      

      final response = await http.post(
        Uri.parse(Urls.Chat_Bot),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': currentUserId,
          'text': 'Show me my prescription details', 
        }),
      );

      print(' Prescription API Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final prescription = ChatPrescriptionModel.fromJson(jsonData);
        

        _initializeMeals(prescription);

        setState(() {
          prescriptionData = prescription;
          if (prescription.data.isNotEmpty && prescription.data.first.doctor != null) {
            selectedDoctorId = prescription.data.first.doctor;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load prescription: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error fetching prescription data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctorList = await DoctorApiService.getDoctorList();
      setState(() {
        doctors = doctorList;
        isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        doctorError = e.toString();
        isLoadingDoctors = false;
      });
    }
  }


  int _getMealIndex(int medicineIndex, int timeSlot) {
    return (medicineIndex * 4) + timeSlot;
  }

  String _formatToHHmmss(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == 'HH:MM AM/PM') return "00:00:00";
    
    // If already in HH:mm:ss format (e.g., 07:35:20)
    final hhmmssRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    if (hhmmssRegex.hasMatch(timeStr)) return timeStr;

    // Handle HH:mm AM/PM or HH:mm formats
    try {
      final parts = timeStr.trim().split(RegExp(r'[:\s]'));
      int hour = 0;
      int minute = 0;
      bool isPM = timeStr.toUpperCase().contains('PM');
      bool isAM = timeStr.toUpperCase().contains('AM');

      if (parts.isNotEmpty) hour = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    } catch (e) {
      return "00:00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SubPageScaffold(
      parentTabIndex: 3,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE0712D), size: 18),
        ),
        title: const Text(
          "Prescription Details",
          style: TextStyle(
            color: Color(0xffE0712D),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading prescription: $errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : prescriptionData == null || prescriptionData!.data.isEmpty
                  ? const Center(
                      child: Text(
                        'No prescription data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [

                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xffE0712D), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Patient's information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    CustomDetails(
                                      name: "Patient's name", 
                                      medicine: prescriptionData!.data.first.patient?.name ?? 'N/A',
                                      errorMessage: fieldErrors['patient_name'],
                                      onChanged: (val) {
                                        setState(() {
                                          final firstData = prescriptionData!.data.first;
                                          prescriptionData!.data.first = firstData.copyWith(
                                            patient: firstData.patient?.copyWith(name: val)
                                          );
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomDetails(
                                      name: "Doctor's name", 
                                      medicine: selectedDoctorId != null 
                                          ? doctors.firstWhere((d) => d.id == selectedDoctorId, orElse: () => DoctorListModel(id: 0, name: 'Unknown', specialization: '', hospitalName: '', designation: '', doctorEmail: '', sex: '')).name
                                          : (prescriptionData!.data.first.doctor != null && doctors.any((d) => d.id == prescriptionData!.data.first.doctor))
                                              ? doctors.firstWhere((d) => d.id == prescriptionData!.data.first.doctor).name
                                              : (prescriptionData!.data.first.doctor != null 
                                                  ? 'Dr. ID: ${prescriptionData!.data.first.doctor}' 
                                                  : 'Select a doctor below'),
                                      errorMessage: fieldErrors['doctor'],
                                    ),
                                    const SizedBox(height: 10),
                                    CustomInfo(
                                      name: "Patient's age", 
                                      age: prescriptionData!.data.first.patient?.age.toString() ?? 'N/A', 
                                      sex: 'Sex', 
                                      gender: prescriptionData!.data.first.patient?.sex ?? 'N/A',
                                      ageError: fieldErrors['patient_age'],
                                      genderError: fieldErrors['patient_gender'],
                                      onChanged: (age, sex) {
                                        setState(() {
                                          final firstData = prescriptionData!.data.first;
                                          prescriptionData!.data.first = firstData.copyWith(
                                            patient: firstData.patient?.copyWith(
                                              age: int.tryParse(age) ?? firstData.patient?.age,
                                              sex: sex,
                                            )
                                          );
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomDetails(
                                      name: 'Health Issue', 
                                      medicine: prescriptionData!.data.first.patient?.healthIssues ?? 'N/A',
                                      onChanged: (val) {
                                        setState(() {
                                          final firstData = prescriptionData!.data.first;
                                          prescriptionData!.data.first = firstData.copyWith(
                                            patient: firstData.patient?.copyWith(healthIssues: val)
                                          );
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          

                          Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 13),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xffE0712D), width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Prescription Details',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        

                                        ...prescriptionData!.data.first.medicines.asMap().entries.map((entry) {
                                          final medicineIndex = entry.key;
                                          final medicine = entry.value;
                                          return _buildMedicineSection(medicine, medicineIndex);
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          

                          _buildMedicalTestsSection(),
                          const SizedBox(height: 15),
                          
                          if (selectedDoctorId != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selected Doctor",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xffE0712D),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  (() {
                                    final doc = doctors.firstWhere(
                                      (d) => d.id == selectedDoctorId,
                                      orElse: () => DoctorListModel(id: 0, name: 'Unknown', specialization: '', hospitalName: '', designation: '', doctorEmail: '', sex: '')
                                    );
                                    return CustomLinkwith(
                                      doctorName: doc.name,
                                      specialization: doc.specialization,
                                      hospital: doc.hospitalName,
                                    );
                                  })(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                          

                          _buildNextAppointmentSection(),
                          const SizedBox(height: 20),
                          

                          _buildDoctorListSection(screenWidth),
                          const SizedBox(height: 20),
                          

                          _buildActionButtons(screenWidth),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }


  Widget _buildMedicineSection(Medicine medicine, int medicineIndex) {
    return Column(
      children: [
        CustomDetails(
          name: 'Medicine Name', 
          medicine: medicine.name,
          errorMessage: fieldErrors['med_name_$medicineIndex'],
          onChanged: (val) {
            setState(() {
              final firstData = prescriptionData!.data.first;
              final medicines = List<Medicine>.from(firstData.medicines);
              medicines[medicineIndex] = medicines[medicineIndex].copyWith(name: val);
              prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
            });
          },
        ),
        const SizedBox(height: 10),
        

        if (medicine.morning != null) ...[
          CustomDetails1(
            name: "Morning", 
            subtitle: medicine.morning?.time ?? 'HH:MM AM/PM', 
            keyboardType: TextInputType.text,
            errorMessage: fieldErrors['med_morning_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  morning: medicines[medicineIndex].morning?.copyWith(time: val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Days", 
            subtitle: medicine.howManyDay?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_days_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  howManyDay: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Stock", 
            subtitle: medicine.stock?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_stock_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  stock: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 0)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 0)] = value;
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  morning: medicines[medicineIndex].morning?.copyWith(
                    afterMeal: value == 'After Meal',
                    beforeMeal: value == 'Before Meal',
                  ),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        
        if (medicine.afternoon != null) ...[
          CustomDetails1(
            name: "Afternoon", 
            subtitle: medicine.afternoon?.time ?? 'HH:MM AM/PM', 
            keyboardType: TextInputType.text,
            errorMessage: fieldErrors['med_afternoon_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  afternoon: medicines[medicineIndex].afternoon?.copyWith(time: val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Days", 
            subtitle: medicine.howManyDay?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_days_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  howManyDay: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Stock", 
            subtitle: medicine.stock?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_stock_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  stock: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 1)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 1)] = value;
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  afternoon: medicines[medicineIndex].afternoon?.copyWith(
                    afterMeal: value == 'After Meal',
                    beforeMeal: value == 'Before Meal',
                  ),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        
        if (medicine.evening != null) ...[
          CustomDetails1(
            name: "Evening", 
            subtitle: medicine.evening?.time ?? 'HH:MM AM/PM', 
            keyboardType: TextInputType.text,
            errorMessage: fieldErrors['med_evening_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  evening: medicines[medicineIndex].evening?.copyWith(time: val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Days", 
            subtitle: medicine.howManyDay?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_days_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  howManyDay: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Stock", 
            subtitle: medicine.stock?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_stock_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  stock: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 2)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 2)] = value;
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  evening: medicines[medicineIndex].evening?.copyWith(
                    afterMeal: value == 'After Meal',
                    beforeMeal: value == 'Before Meal',
                  ),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            },
          ),
          const SizedBox(height: 15),
        ],
        
        if (medicine.night != null) ...[
          CustomDetails1(
            name: "Night", 
            subtitle: medicine.night?.time ?? 'HH:MM AM/PM', 
            keyboardType: TextInputType.text,
            errorMessage: fieldErrors['med_night_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  night: medicines[medicineIndex].night?.copyWith(time: val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Days", 
            subtitle: medicine.howManyDay?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_days_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  howManyDay: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          CustomDetails1(
            name: "Stock", 
            subtitle: medicine.stock?.toString() ?? '0', 
            keyboardType: TextInputType.number,
            errorMessage: fieldErrors['med_stock_$medicineIndex'],
            onChanged: (val) {
              setState(() {
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  stock: int.tryParse(val),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            }
          ),
          const SizedBox(height: 5),
          CustomBull(
            selectedMeal: selectedMeals[_getMealIndex(medicineIndex, 3)],
            onChanged: (value) {
              setState(() {
                selectedMeals[_getMealIndex(medicineIndex, 3)] = value;
                final firstData = prescriptionData!.data.first;
                final medicines = List<Medicine>.from(firstData.medicines);
                medicines[medicineIndex] = medicines[medicineIndex].copyWith(
                  night: medicines[medicineIndex].night?.copyWith(
                    afterMeal: value == 'After Meal',
                    beforeMeal: value == 'Before Meal',
                  ),
                );
                prescriptionData!.data.first = firstData.copyWith(medicines: medicines);
              });
            },
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }


  Widget _buildMedicalTestsSection() {
    final medicalTests = prescriptionData!.data.first.medicalTests;
    
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE0712D), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical tests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  

                  if (medicalTests.isEmpty)
                    const Text('No medical tests available')
                  else
                    ...medicalTests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final test = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomDetails(
                          name: 'Test ${index + 1}', 
                          medicine: test.toString()
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildNextAppointmentSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: CustomDetails(
            name: "Next Appointment", 
            medicine: _nextAppointmentController.text.isNotEmpty 
                ? _nextAppointmentController.text 
                : (prescriptionData!.data.first.nextAppointmentDate ?? 'YYYY-MM-DD'),
            onChanged: (val) {
              setState(() {
                _nextAppointmentController.text = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorListSection(double screenWidth) {
    // Hide if doctor is already provided in the prescription data
    if (prescriptionData?.data.first.doctor != null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width * 0.96,
          decoration: BoxDecoration(
            color: const Color(0xffE0712D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              "Doctor List",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        

        Container(
          height: 200,
          child: isLoadingDoctors
              ? const Center(child: CircularProgressIndicator())
              : doctorError != null
                  ? Center(
                      child: Text(
                        'Error loading doctors',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        final isSelected = selectedDoctorId == doctor.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedDoctorId = doctor.id;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? const Color(0xffE0712D) : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: CustomLinkwith(
                                doctorName: doctor.name,
                                specialization: doctor.specialization,
                                hospital: doctor.hospitalName,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }


  Widget _buildActionButtons(double screenWidth) {
    return Row(
      children: [
        SizedBox(width: screenWidth * 0.18),
        CustomMinibutton(
          text: "save",
          onTap: _handleSave,
          textcolor: Colors.white,
          backgroundColor: const Color(0xffE0712D),
        ),
        SizedBox(width: screenWidth * 0.05),
        CustomMinibutton(
          text: "Decline",
          onTap: () {

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AppShell(initialIndex: 3)),
                  (route) => false,
            );
          },
          textcolor: const Color(0xffE0712D),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }
}
