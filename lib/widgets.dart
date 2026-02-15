import 'package:flutter/material.dart';
import 'theme.dart';
import '../audio.dart';

Color _getShadowColor(Color color) {
  final HSLColor hsl = HSLColor.fromColor(color);
  final HSLColor hslDark = hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class DuoButton extends StatefulWidget {
  final String? text; // <-- AHORA ES OPCIONAL (Puede ser null)
  final VoidCallback? onPressed;
  final Color color;
  final Color? shadowColor;
  final IconData? icon;

  const DuoButton({
    super.key,
    this.text, // <-- Quitamos el "required"
    required this.onPressed,
    this.color = duoBlue,
    this.shadowColor,
    this.icon,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color mainColor = widget.onPressed == null
        ? duoBorder
        : (widget.color == duoSurface ? duoSurface : widget.color);

    Color shadow;
    if (widget.onPressed == null) {
      shadow = const Color(0xFF2A3A44);
    } else if (widget.color == duoSurface) {
      shadow = duoBorder;
    } else {
      shadow = widget.shadowColor ?? _getShadowColor(mainColor);
    }

    Color contentColor;
    if (widget.onPressed == null) {
      contentColor = duoTextSub;
    } else if (widget.color == duoSurface) {
      contentColor = AppTheme.primary;
    } else {
      contentColor = Colors.white;
    }

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          Sonidos.playClick();
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0, bottom: _isPressed ? 0 : 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(color: shadow, offset: const Offset(0, 4), blurRadius: 0)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: contentColor, size: 24),
              // Solo ponemos espacio si también hay texto
              if (widget.text != null) const SizedBox(width: 10)
            ],
            if (widget.text != null)
              Flexible(
                child: Text(
                  widget.text!.toUpperCase(),
                  style: duoFont(size: 16, color: contentColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DuoInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)? onSubmitted;

  const DuoInput({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: duoSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: duoBorder, width: 2),
      ),
      child: TextField(
        controller: controller,
        style: duoFont(size: 18, color: duoTextMain),
        onSubmitted: onSubmitted,
        cursorColor: AppTheme.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: duoTextSub, fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}