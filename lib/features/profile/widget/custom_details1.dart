import 'package:flutter/material.dart';

class CustomDetails1 extends StatefulWidget {
  final String name;
  final String subtitle;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? errorMessage;

  const CustomDetails1({
    super.key,
    required this.name,
    required this.subtitle ,
    this.onChanged,
    this.keyboardType,
    this.errorMessage,
  });

  @override
  State<CustomDetails1> createState() => _CustomDetails1State();
}

class _CustomDetails1State extends State<CustomDetails1> {
  late TextEditingController _subtitleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _subtitleController = TextEditingController(text: widget.subtitle);
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomDetails1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subtitle != oldWidget.subtitle && !_isEditing) {
      _subtitleController.text = widget.subtitle;
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              child: _isEditing
                  ? TextField(
                controller: _subtitleController,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.subtitle,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value.isEmpty ? widget.subtitle : value);
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _isEditing = false;
                    if (value.isEmpty) {
                      _subtitleController.text = widget.subtitle;
                    }
                  });
                },
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    _subtitleController.clear();
                    _isEditing = true;
                  });
                },
                child: Text(
                  _subtitleController.text.isEmpty ? widget.subtitle : _subtitleController.text,
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
