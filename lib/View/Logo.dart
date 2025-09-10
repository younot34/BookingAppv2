import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class LogoWidget extends StatefulWidget {
  final String? imageUrlOrBase64;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const LogoWidget({super.key, this.imageUrlOrBase64, this.width, this.height, this.onTap});

  @override
  _LogoWidgetState createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  Uint8List? _bytes;

  @override
  void didUpdateWidget(covariant LogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrlOrBase64 != oldWidget.imageUrlOrBase64) {
      _decodeBase64();
    }
  }

  @override
  void initState() {
    super.initState();
    _decodeBase64();
  }

  void _decodeBase64() {
    if (widget.imageUrlOrBase64 == null || widget.imageUrlOrBase64!.startsWith('http')) {
      _bytes = null;
    } else {
      try {
        _bytes = base64Decode(widget.imageUrlOrBase64!);
      } catch (e) {
        _bytes = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_bytes != null) {
      content = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrlOrBase64 != null && widget.imageUrlOrBase64!.startsWith('http')) {
      content = Image.network(
        widget.imageUrlOrBase64!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      );
    } else {
      content = const Icon(Icons.image_not_supported, size: 40, color: Colors.white);
    }

    // Bungkus dengan GestureDetector agar onTap bisa dipanggil
    return GestureDetector(
      onTap: widget.onTap,
      child: content,
    );
  }

}