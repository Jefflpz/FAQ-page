import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExpandableQuestion extends StatefulWidget {
  final String question;
  final String answer;
  const ExpandableQuestion({super.key, required this.question, required this.answer});

  @override
  State<ExpandableQuestion> createState() => _ExpandableQuestionState();
}

class _ExpandableQuestionState extends State<ExpandableQuestion> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<Color?> _questionColor;
  late final Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _questionColor = ColorTween(begin: Colors.white, end: Colors.grey[500]).animate(_controller);
    _arrowRotation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.purple[900]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: _isExpanded ? 8 : 0,
                          horizontal: _isExpanded ? 12 : 20,
                        ),
                        child: Text(
                          widget.question,
                          style: TextStyle(
                            fontSize: 16,
                            color: _questionColor.value,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: _arrowRotation.value * 2 * math.pi,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        onPressed: _toggleExpand,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_isExpanded) const SizedBox(height: 8),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Text(
                  widget.answer,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
