import 'package:flutter/material.dart';

class FotoNahled extends StatefulWidget {
  final List<String> urls;
  final int startIndex;
  const FotoNahled({super.key, required this.urls, required this.startIndex});

  @override
  State<FotoNahled> createState() => _FotoNahledState();
}

class _FotoNahledState extends State<FotoNahled> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.urls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                    color: Colors.white, size: 64)),
          ),
        ),
      ),
    );
  }
}
