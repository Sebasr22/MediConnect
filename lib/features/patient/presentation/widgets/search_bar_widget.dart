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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSearchPressed?.call(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o especialidad...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: widget.onSearchPressed != null
              ? IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.blue.shade600,
                  ),
                  onPressed: widget.onSearchPressed,
                  tooltip: 'Buscar',
                )
              : Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  tooltip: 'Limpiar',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}