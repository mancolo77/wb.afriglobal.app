import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchEntry {
  final String id;
  final String sport;
  final String participants;
  final String date; // YYYY-MM-DD
  final String place;
  final String? score;
  final String notes;
  final bool isAttended;
  final bool isFavorite;

  const MatchEntry({
    required this.id,
    required this.sport,
    required this.participants,
    required this.date,
    required this.place,
    this.score,
    required this.notes,
    required this.isAttended,
    required this.isFavorite,
  });

  MatchEntry copyWith({
    String? sport,
    String? participants,
    String? date,
    String? place,
    String? score,
    String? notes,
    bool? isAttended,
    bool? isFavorite,
  }) {
    return MatchEntry(
      id: id,
      sport: sport ?? this.sport,
      participants: participants ?? this.participants,
      date: date ?? this.date,
      place: place ?? this.place,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      isAttended: isAttended ?? this.isAttended,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sport': sport,
        'participants': participants,
        'date': date,
        'place': place,
        'score': score,
        'notes': notes,
        'isAttended': isAttended,
        'isFavorite': isFavorite,
      };

  factory MatchEntry.fromJson(Map<String, dynamic> json) => MatchEntry(
        id: json['id'] as String,
        sport: json['sport'] as String? ?? 'Football',
        participants: json['participants'] as String? ?? '',
        date: json['date'] as String? ?? '',
        place: json['place'] as String? ?? '',
        score: json['score'] as String?,
        notes: json['notes'] as String? ?? '',
        isAttended: json['isAttended'] as bool? ?? true,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}

class MatchJournalService with ChangeNotifier {
  static final MatchJournalService _instance = MatchJournalService._internal();
  factory MatchJournalService() => _instance;
  MatchJournalService._internal();

  final List<MatchEntry> _entries = [];
  List<MatchEntry> get entries => List.unmodifiable(_entries);

  List<MatchEntry> get attendedEntries =>
      _entries.where((e) => e.isAttended).toList();

  List<MatchEntry> get plannedEntries =>
      _entries.where((e) => !e.isAttended).toList();

  List<MatchEntry> get favoriteEntries =>
      _entries.where((e) => e.isFavorite && e.isAttended).toList();

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('match_journal_entries');
      _entries.clear();

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = json.decode(raw);
        _entries.addAll(list.map((e) => MatchEntry.fromJson(e as Map<String, dynamic>)));
      } else {
        // Sample entries
        _entries.addAll([
          const MatchEntry(
            id: 'm_1',
            sport: 'Football',
            participants: 'Arsenal vs Chelsea',
            date: '2026-10-15',
            place: 'Emirates Stadium',
            score: '2 : 1',
            notes: 'Incredible atmosphere! Winning goal in the 88th minute.',
            isAttended: true,
            isFavorite: true,
          ),
          const MatchEntry(
            id: 'm_2',
            sport: 'Hockey',
            participants: 'Maple Leafs vs Bruins',
            date: '2026-10-22',
            place: 'Scotiabank Arena',
            score: '3 : 2 (OT)',
            notes: 'Great overtime period, intense physical game.',
            isAttended: true,
            isFavorite: false,
          ),
          const MatchEntry(
            id: 'm_3',
            sport: 'Basketball',
            participants: 'Lakers vs Celtics',
            date: '2026-11-05',
            place: 'Crypto.com Arena',
            score: null,
            notes: 'Section A3, row 12, great court view.',
            isAttended: false,
            isFavorite: false,
          ),
        ]);
        await _save();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'match_journal_entries',
        json.encode(_entries.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void addEntry(MatchEntry entry) {
    _entries.insert(0, entry);
    _save();
    notifyListeners();
  }

  void updateEntry(MatchEntry updated) {
    final idx = _entries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _entries[idx] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _entries[idx] = _entries[idx].copyWith(isFavorite: !_entries[idx].isFavorite);
      _save();
      notifyListeners();
    }
  }

  void toggleAttended(String id) {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _entries[idx] = _entries[idx].copyWith(isAttended: !_entries[idx].isAttended);
      _save();
      notifyListeners();
    }
  }
}

