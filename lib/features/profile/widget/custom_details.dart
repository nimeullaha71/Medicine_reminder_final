import 'package:flutter/material.dart';

class CustomDetails extends StatefulWidget {
  final String name;
  final String medicine;
  final Function(String)? onChanged;
  final String? errorMessage;
  final bool isEditable;

  const CustomDetails({
    super.key,
    required this.name,
    required this.medicine,
    this.onChanged,
    this.errorMessage,
    this.isEditable = true,
  });

  @override
  State<CustomDetails> createState() => _CustomDetailsState();
}

class _CustomDetailsState extends State<CustomDetails> {
  late TextEditingController _medicineController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _medicineController = TextEditingController(text: widget.medicine);
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.medicine != oldWidget.medicine && !_isEditing) {
      _medicineController.text = widget.medicine;
    }
  }

  Widget _buildError() {
    if (widget.errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Text(
        widget.errorMessage!,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContent(),
        _buildError(),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffFFF0E6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
              child: widget.isEditable
                  ? TextField(
                controller: _medicineController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.medicine,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value.isEmpty ? widget.medicine : value);
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _isEditing = false;
                    if (value.isEmpty) {
                      _medicineController.text = widget.medicine;
                    }
                  });
                },
              )
                  : GestureDetector(
                onTap: widget.isEditable ? () {
                  setState(() {
                    _medicineController.clear();
                    _isEditing = true;
                  });
                } : null,
                child: Text(
                  _medicineController.text.isEmpty ? widget.medicine : _medicineController.text,
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
