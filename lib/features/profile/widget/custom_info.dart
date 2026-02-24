import 'package:flutter/material.dart';

class CustomInfo extends StatefulWidget {
  final String name;
  final String age;
  final String sex;
  final String gender;
  final Function(String, String)? onChanged;
  final String? ageError;
  final String? genderError;
  final bool isEditable;

  const CustomInfo({
    super.key,
    required this.name,
    required this.age,
    required this.sex,
    required this.gender,
    this.onChanged,
    this.ageError,
    this.genderError,
    this.isEditable = true,
  });

  @override
  State<CustomInfo> createState() => _CustomInfoState();
}

class _CustomInfoState extends State<CustomInfo> {
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  bool _isEditingAge = false;
  bool _isEditingGender = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.age);
    _genderController = TextEditingController(text: widget.gender);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.age != oldWidget.age && !_isEditingAge) {
      _ageController.text = widget.age;
    }
    if (widget.gender != oldWidget.gender && !_isEditingGender) {
      _genderController.text = widget.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContent(),
        if (widget.ageError != null || widget.genderError != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              widget.ageError ?? widget.genderError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffFFF0E6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffE0712D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: _isEditingAge
                  ? TextField(
                controller: _ageController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.age,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value.isEmpty ? widget.age : value, _genderController.text.isEmpty ? widget.gender : _genderController.text);
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _isEditingAge = false;
                    if (value.isEmpty) {
                      _ageController.text = widget.age;
                    }
                  });
                },
              )
                  : GestureDetector(
                onTap: widget.isEditable ? () {
                  setState(() {
                    _ageController.clear();
                    _isEditingAge = true;
                  });
                } : null,
                child: Text(
                  _ageController.text.isEmpty ? widget.age : _ageController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffE0712D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              widget.sex,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: _isEditingGender
                  ? TextField(
                controller: _genderController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.gender,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(_ageController.text.isEmpty ? widget.age : _ageController.text, value.isEmpty ? widget.gender : value);
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _isEditingGender = false;
                    if (value.isEmpty) {
                      _genderController.text = widget.gender;
                    }
                  });
                },
              )
                  : GestureDetector(
                onTap: widget.isEditable ? () {
                  setState(() {
                    _genderController.clear();
                    _isEditingGender = true;
                  });
                } : null,
                child: Text(
                  _genderController.text.isEmpty ? widget.gender : _genderController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
