import 'package:flutter/material.dart';
import '../../services/match_journal_service.dart';
import '../../theme/app_theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _service = MatchJournalService();
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _showAddPlannedDialog() {
    String sport = 'Football';
    final participantsCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
      text: DateTime.now().add(const Duration(days: 3)).toIso8601String().substring(0, 10),
    );
    final placeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Schedule Match Visit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: sport,
                  decoration: InputDecoration(
                    labelText: 'Sport',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                  items: ['Football', 'Hockey', 'Basketball', 'Tennis', 'Volleyball']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setSheetState(() => sport = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: participantsCtrl,
                  decoration: InputDecoration(
                    labelText: 'Match / Event',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateCtrl,
                  decoration: InputDecoration(
                    labelText: 'Date of Visit (YYYY-MM-DD)',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: placeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Stadium / Arena / Venue',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (seat, row, ticket details)',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    onPressed: () {
                      final pText = participantsCtrl.text.trim();
                      if (pText.isEmpty) return;

                      _service.addEntry(
                        MatchEntry(
                          id: 'match_${DateTime.now().millisecondsSinceEpoch}',
                          sport: sport,
                          participants: pText,
                          date: dateCtrl.text.trim(),
                          place: placeCtrl.text.trim(),
                          score: null,
                          notes: notesCtrl.text.trim(),
                          isAttended: false,
                          isFavorite: false,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = _service.entries;
    final sorted = List<MatchEntry>.from(allEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final filtered = sorted.where((e) {
      if (_filterStatus == 'Scheduled') return !e.isAttended;
      if (_filterStatus == 'Attended') return e.isAttended;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Upcoming visits and archive by date',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: _showAddPlannedDialog,
                    icon: const Icon(Icons.add_alarm_rounded, size: 18),
                    label: const Text(
                      'Schedule',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Scheduled', 'Attended'].map((status) {
                    final isSelected = _filterStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _filterStatus = status),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.darkNav : AppTheme.surfaceSecondary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.darkNav : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textMain,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Entries List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 56, color: AppTheme.textSecondary.withAlpha(120)),
                          const SizedBox(height: 10),
                          const Text(
                            'No events found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Schedule a stadium visit in the upcoming days',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isAttended = item.isAttended;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: isAttended ? AppTheme.border : AppTheme.accentYellow,
                              width: isAttended ? 1 : 1.5,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAttended
                                            ? AppTheme.primary.withAlpha(20)
                                            : AppTheme.accentYellow.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isAttended
                                                ? Icons.check_circle_outline_rounded
                                                : Icons.schedule_rounded,
                                            size: 14,
                                            color: isAttended ? AppTheme.primary : AppTheme.onYellow,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isAttended ? 'Attended' : 'Scheduled',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isAttended ? AppTheme.primary : AppTheme.onYellow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      item.date,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.participants,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.sport} • ${item.place}',
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                ),
                                if (item.notes.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    item.notes,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (!isAttended)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          minimumSize: const Size(0, 40),
                                        ),
                                        onPressed: () => _service.toggleAttended(item.id),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Mark as Attended'),
                                      )
                                    else
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.textSecondary,
                                          side: const BorderSide(color: AppTheme.border),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          minimumSize: const Size(0, 40),
                                        ),
                                        onPressed: () => _service.toggleAttended(item.id),
                                        icon: const Icon(Icons.undo_rounded, size: 16),
                                        label: const Text('Remove Mark'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
