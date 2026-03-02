import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/tag.dart';

class TagFormDialog extends StatefulWidget {
  final Tag? existingTag;
  final Function(String name, String? color) onSave;

  const TagFormDialog({
    super.key,
    this.existingTag,
    required this.onSave,
  });

  @override
  State<TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<TagFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _colorController;
  
  Color _selectedColor = Colors.blue; 
  bool _hasColor = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingTag?.name ?? '');
    
    final String initialHex = widget.existingTag?.color ?? '';
    if (initialHex.isNotEmpty) {
      _hasColor = true;
      _selectedColor = _getColorFromHex(initialHex);
      _colorController = TextEditingController(text: initialHex.toUpperCase());
    } else {
      _hasColor = false;
      _colorController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.tryParse(hexColor, radix: 16) ?? 0xFF2196F3);
  }

  String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  void _onWheelColorChanged(Color newColor) {
    setState(() {
      _hasColor = true;
      _selectedColor = newColor;
      
      final newHex = _colorToHex(newColor);
      if (_colorController.text != newHex) {
        _colorController.text = newHex;
        _colorController.selection = TextSelection.collapsed(offset: newHex.length);
      }
    });
  }

  void _onHexTextChanged(String value) {
    final cleanHex = value.trim().toUpperCase();
    
    if (cleanHex.isEmpty) {
      setState(() => _hasColor = false);
      return;
    }

    if (cleanHex.startsWith('#') && cleanHex.length == 7) {
      setState(() {
        _hasColor = true;
        _selectedColor = _getColorFromHex(cleanHex);
      });
    } else if (!cleanHex.startsWith('#') && cleanHex.length == 6) {
      setState(() {
        _hasColor = true;
        _selectedColor = _getColorFromHex('#$cleanHex');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTag == null ? 'New Tag' : 'Edit Tag'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tag Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tag Color', 
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                  ),
                  if (_hasColor)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasColor = false;
                          _colorController.clear();
                        });
                      },
                      icon: const Icon(Icons.format_color_reset, size: 16),
                      label: const Text('Remove Color'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hasColor ? 1.0 : 0.4,
                  child: HueSaturationWheel(
                    color: _selectedColor,
                    onChanged: _onWheelColorChanged,
                    size: 200, 
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _colorController,
                onChanged: _onHexTextChanged,
                decoration: InputDecoration(
                  labelText: 'Hexadecimal', 
                  hintText: '#FF0000',
                  prefixIcon: Icon(Icons.tag, color: _hasColor ? _selectedColor : null),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final finalColor = _hasColor ? _colorController.text.trim() : null;
              widget.onSave(_nameController.text.trim(), finalColor);
              Navigator.pop(context);
            }
          },
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class HueSaturationWheel extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onChanged;
  final double size;

  const HueSaturationWheel({
    super.key,
    required this.color,
    required this.onChanged,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _handleGesture(details.localPosition),
      onTapDown: (details) => _handleGesture(details.localPosition),
      child: CustomPaint(
        size: Size(size, size),
        painter: _WheelPainter(color),
      ),
    );
  }

  void _handleGesture(Offset position) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;
    
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    final double distance = math.sqrt(dx * dx + dy * dy);
    final double saturation = (distance / radius).clamp(0.0, 1.0);

    final double angle = math.atan2(dy, dx);
    double hue = (angle * 180 / math.pi) % 360;
    if (hue < 0) hue += 360; 

    final newColor = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
    onChanged(newColor);
  }
}

class _WheelPainter extends CustomPainter {
  final Color selectedColor;

  _WheelPainter(this.selectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweepGradient = SweepGradient(
      colors: const [
        Color(0xFFFF0000), 
        Color(0xFFFFFF00), 
        Color(0xFF00FF00), 
        Color(0xFF00FFFF), 
        Color(0xFF0000FF), 
        Color(0xFFFF00FF), 
        Color(0xFFFF0000), 
      ],
    );

    final paintHue = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paintHue);

    final radialGradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.white.withValues(alpha: 0.0),
      ],
    );

    final paintSat = Paint()
      ..shader = radialGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paintSat);

    final hsv = HSVColor.fromColor(selectedColor);
    final theta = hsv.hue * math.pi / 180;
    final r = hsv.saturation * radius;

    final thumbX = center.dx + r * math.cos(theta);
    final thumbY = center.dy + r * math.sin(theta);
    final thumbCenter = Offset(thumbX, thumbY);

    final thumbPaintOuter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final thumbPaintInner = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thumbPaintFill = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(thumbCenter, 14, thumbPaintFill);
    canvas.drawCircle(thumbCenter, 14, thumbPaintOuter);
    canvas.drawCircle(thumbCenter, 14, thumbPaintInner);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.selectedColor != selectedColor;
  }
}