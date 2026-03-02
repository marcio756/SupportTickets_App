import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/tag.dart';

/// A reusable dialog for creating or updating a tag.
/// Features a custom, zero-dependency Color Wheel for intuitive color selection.
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

  /// Safely converts a Hex string to a Flutter Color object.
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.tryParse(hexColor, radix: 16) ?? 0xFF2196F3);
  }

  /// Converts a Flutter Color object back to a standard 6-character Hex string.
  String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  /// Triggers when the user interacts with the color wheel.
  void _onWheelColorChanged(Color newColor) {
    setState(() {
      _hasColor = true;
      _selectedColor = newColor;
      
      final newHex = _colorToHex(newColor);
      if (_colorController.text != newHex) {
        _colorController.text = newHex;
        // Pushes cursor to the end of the text field
        _colorController.selection = TextSelection.collapsed(offset: newHex.length);
      }
    });
  }

  /// Triggers when the user manually types a hex code in the text field.
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
      title: Text(widget.existingTag == null ? 'Nova Tag' : 'Editar Tag'),
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
                  labelText: 'Nome da Tag *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cor da Tag', 
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
                      label: const Text('Remover Cor'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Render the Custom Color Wheel
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hasColor ? 1.0 : 0.4,
                  child: HueSaturationWheel(
                    color: _selectedColor,
                    onChanged: _onWheelColorChanged,
                    size: 200, // Fixed optimal size for the dialog
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
          child: const Text('Cancelar'),
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
          child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// A lightweight, custom-painted HSV Color Wheel.
/// Uses mathematical polar coordinates to define Hue (angle) and Saturation (distance).
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

  /// Calculates the selected color based on the touch interaction coordinates.
  void _handleGesture(Offset position) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;
    
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Saturation is determined by the distance from the center
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double saturation = (distance / radius).clamp(0.0, 1.0);

    // Hue is determined by the angle around the center
    final double angle = math.atan2(dy, dx);
    double hue = (angle * 180 / math.pi) % 360;
    if (hue < 0) hue += 360; // Normalize negative angles

    // We maintain Value (Brightness) at 1.0 to ensure vivid tag colors
    final newColor = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
    onChanged(newColor);
  }
}

/// Paints the actual Sweep and Radial gradients to construct the wheel visually.
class _WheelPainter extends CustomPainter {
  final Color selectedColor;

  _WheelPainter(this.selectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw the Base Hue Gradient (Full RGB Spectrum)
    final sweepGradient = SweepGradient(
      colors: const [
        Color(0xFFFF0000), // Red
        Color(0xFFFFFF00), // Yellow
        Color(0xFF00FF00), // Green
        Color(0xFF00FFFF), // Cyan
        Color(0xFF0000FF), // Blue
        Color(0xFFFF00FF), // Magenta
        Color(0xFFFF0000), // Red
      ],
    );

    final paintHue = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paintHue);

    // 2. Draw the Saturation overlay (White center fading to transparent edges)
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

    // 3. Draw the Selection Thumb
    final hsv = HSVColor.fromColor(selectedColor);
    final theta = hsv.hue * math.pi / 180;
    final r = hsv.saturation * radius;

    // Find thumb cartesian coordinates
    final thumbX = center.dx + r * math.cos(theta);
    final thumbY = center.dy + r * math.sin(theta);
    final thumbCenter = Offset(thumbX, thumbY);

    // Thumb borders for contrast
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