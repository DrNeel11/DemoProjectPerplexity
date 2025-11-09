import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paper.dart';
import '../models/research_query.dart';

class StorageService {
  static const String _paperKey = 'papers';
  static const String _queryKey = 'queries';
  
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }

  // Paper operations
  Future<void> savePaper(Paper paper) async {
    final prefs = await _getPrefs();
    final papers = await getAllPapers();
    papers.removeWhere((p) => p.id == paper.id);
    papers.add(paper);
    
    final papersJson = papers.map((p) => p.toJson()).toList();
    await prefs.setString(_paperKey, json.encode(papersJson));
  }

  Future<void> savePapers(List<Paper> papers) async {
    for (var paper in papers) {
      await savePaper(paper);
    }
  }

  Future<Paper?> getPaper(String id) async {
    final papers = await getAllPapers();
    try {
      return papers.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Paper>> getAllPapers() async {
    final prefs = await _getPrefs();
    final papersString = prefs.getString(_paperKey);
    
    if (papersString == null) return [];
    
    try {
      final papersList = json.decode(papersString) as List;
      return papersList
          .map((e) => Paper.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error loading papers: $e');
      return [];
    }
  }

  Future<List<Paper>> searchPapers(String query) async {
    final papers = await getAllPapers();
    final lowerQuery = query.toLowerCase();
    return papers.where((paper) {
      return paper.title.toLowerCase().contains(lowerQuery) ||
          paper.abstract.toLowerCase().contains(lowerQuery) ||
          paper.methodology.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Query operations
  Future<void> saveQuery(ResearchQuery query) async {
    final prefs = await _getPrefs();
    final queries = await getAllQueries();
    queries.removeWhere((q) => q.id == query.id);
    queries.add(query);
    
    final queriesJson = queries.map((q) => q.toJson()).toList();
    await prefs.setString(_queryKey, json.encode(queriesJson));
  }

  Future<ResearchQuery?> getQuery(String id) async {
    final queries = await getAllQueries();
    try {
      return queries.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<ResearchQuery>> getAllQueries() async {
    final prefs = await _getPrefs();
    final queriesString = prefs.getString(_queryKey);
    
    if (queriesString == null) return [];
    
    try {
      final queriesList = json.decode(queriesString) as List;
      final queries = queriesList
          .map((e) => ResearchQuery.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      queries.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
      return queries;
    } catch (e) {
      print('Error loading queries: $e');
      return [];
    }
  }

  Future<void> deleteQuery(String id) async {
    final prefs = await _getPrefs();
    final queries = await getAllQueries();
    queries.removeWhere((q) => q.id == id);
    
    final queriesJson = queries.map((q) => q.toJson()).toList();
    await prefs.setString(_queryKey, json.encode(queriesJson));
  }

  Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_paperKey);
    await prefs.remove(_queryKey);
  }
}
