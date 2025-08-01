import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSearchPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSearchPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el controller para actualizar el suffixIcon
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Actualizar el estado cuando cambie el texto
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSearchPressed?.call(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar doctores, especialidades...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: widget.onSearchPressed != null
                ? GestureDetector(
                    onTap: widget.onSearchPressed,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                : Icon(
                    Icons.search_rounded,
                    color: Colors.blue.shade600,
                    size: 22,
                  ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onChanged('');
                        },
                        tooltip: 'Limpiar búsqueda',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.mic_outlined,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ],
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.mic_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}