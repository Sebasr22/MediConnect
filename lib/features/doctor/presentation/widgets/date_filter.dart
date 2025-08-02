import 'package:flutter/material.dart';

class DateFilter extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateFilter({
    super.key,
    required this.onDateRangeSelected,
  });

  @override
  State<DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.teal.shade50.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade400,
                      Colors.teal.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Filtrar por fechas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.teal.shade800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              if (_startDate != null || _endDate != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _clearFilter,
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    tooltip: 'Limpiar filtro',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickFilterChip(
                label: 'Hoy',
                isSelected: _isToday(),
                onTap: () => _selectTodayFilter(),
              ),
              _QuickFilterChip(
                label: 'Esta semana',
                isSelected: _isThisWeek(),
                onTap: () => _selectThisWeekFilter(),
              ),
              _QuickFilterChip(
                label: 'Este mes',
                isSelected: _isThisMonth(),
                onTap: () => _selectThisMonthFilter(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Start Date
              Expanded(
                child: _DateButton(
                  label: 'Fecha inicio',
                  date: _startDate,
                  onPressed: () => _selectStartDate(context),
                ),
              ),
              const SizedBox(width: 12),
              // End Date
              Expanded(
                child: _DateButton(
                  label: 'Fecha fin',
                  date: _endDate,
                  onPressed: () => _selectEndDate(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
      _applyFilter();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyFilter();
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onDateRangeSelected(null, null);
  }

  void _applyFilter() {
    if (_startDate != null && _endDate != null) {
      widget.onDateRangeSelected(_startDate, _endDate);
    } else if (_startDate != null) {
      // If only start date is selected, filter from start date to end of day
      widget.onDateRangeSelected(
        _startDate,
        _startDate!.add(const Duration(days: 1)),
      );
    }
  }

  // Quick filter methods
  bool _isToday() {
    final now = DateTime.now();
    return _startDate != null && 
           _endDate != null &&
           _isSameDay(_startDate!, now) &&
           _isSameDay(_endDate!, now.add(const Duration(days: 1)));
  }

  bool _isThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _startDate != null && 
           _endDate != null &&
           _isSameDay(_startDate!, startOfWeek) &&
           _isSameDay(_endDate!, endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _startDate != null && 
           _endDate != null &&
           _isSameDay(_startDate!, startOfMonth) &&
           _isSameDay(_endDate!, endOfMonth.add(const Duration(days: 1)));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _selectTodayFilter() {
    final now = DateTime.now();
    setState(() {
      _startDate = now;
      _endDate = now.add(const Duration(days: 1));
    });
    _applyFilter();
  }

  void _selectThisWeekFilter() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    setState(() {
      _startDate = startOfWeek;
      _endDate = endOfWeek.add(const Duration(days: 1));
    });
    _applyFilter();
  }

  void _selectThisMonthFilter() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    setState(() {
      _startDate = startOfMonth;
      _endDate = endOfMonth.add(const Duration(days: 1));
    });
    _applyFilter();
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade400,
                    Colors.teal.shade600,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.teal.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.teal.shade200.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.teal.shade700,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPressed;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.teal.shade50.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? Colors.teal.shade300 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade100.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: date != null ? Colors.teal.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: date != null ? Colors.teal.shade600 : Colors.grey.shade500,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'Seleccionar fecha',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: date != null ? Colors.teal.shade800 : Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}