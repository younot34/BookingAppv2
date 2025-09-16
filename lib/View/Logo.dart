import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class LogoWidget extends StatefulWidget {
  final String? imageUrlOrBase64;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const LogoWidget({
    super.key,
    this.imageUrlOrBase64,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  _LogoWidgetState createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void didUpdateWidget(covariant LogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrlOrBase64 != oldWidget.imageUrlOrBase64) {
      _decodeImage();
    }
  }

  /// Bersihkan base64 kalau ada prefix "data:image/png;base64,"
  String _cleanBase64(String input) {
    if (input.startsWith("data:image")) {
      return input.split(",").last;
    }
    return input;
  }

  void _decodeImage() {
    if (widget.imageUrlOrBase64 == null ||
        widget.imageUrlOrBase64!.trim().isEmpty) {
      _bytes = null;
      return;
    }

    final value = widget.imageUrlOrBase64!.trim();

    if (value.startsWith("http")) {
      // URL → biarkan Image.network yang handle
      _bytes = null;
    } else {
      // Base64
      try {
        final clean = _cleanBase64(value);
        _bytes = base64Decode(clean);
      } catch (e) {
        print("⚠️ Base64 decode error: $e");
        _bytes = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_bytes != null) {
      // Base64 berhasil di-decode
      content = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrlOrBase64 != null &&
        widget.imageUrlOrBase64!.startsWith("http")) {
      // URL
      content = Image.network(
        widget.imageUrlOrBase64!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 40, color: Colors.red),
      );
    } else {
      // Fallback
      content = const Icon(Icons.image_not_supported,
          size: 40, color: Colors.grey);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: content,
    );
  }
}