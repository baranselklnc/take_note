/// API endpoint constants
class ApiConstants {
  // Base URL - Android emülatör için 10.0.2.2 kullanın
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // ===== CORE ENDPOINTS =====
  
  // Health & Info
  static const String root = '/';
  static const String health = '/health';
  
  // ===== NOTES CRUD ENDPOINTS =====
  
  // Basic CRUD
  static const String notes = '/notes';
  static String noteById(String id) => '/notes/$id';
  
  // Notes Operations
  static String restoreNote(String id) => '/notes/$id/restore';
  static String togglePin(String id) => '/notes/$id/pin';
  
  // ===== SEARCH ENDPOINTS =====
  
  // Search
  static const String searchNotes = '/notes/search';
  static const String semanticSearch = '/notes/semantic-search';
  
  // ===== AI ENDPOINTS =====
  
  // AI Processing
  static String summarizeNote(String id) => '/notes/$id/summarize';
  static String categorizeNote(String id) => '/notes/$id/categorize';
  static String autoTagNote(String id) => '/notes/$id/auto-tag';
  static String aiProcessNote(String id) => '/notes/$id/ai-process';
  static const String processContent = '/ai/process-content';
  
  // ===== HEADERS =====
  
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
  
  // ===== QUERY PARAMETERS =====
  
  static const String pageParam = 'page';
  static const String sizeParam = 'size';
  static const String searchParam = 'search';
  static const String limitParam = 'limit';
}
