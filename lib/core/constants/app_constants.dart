/// App-wide constants
class AppConstants {
  // API
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiVersion = '/api/v1';
  
  // Storage
  static const String notesBoxName = 'notes_box';
  static const String userBoxName = 'user_box';
  static const String syncQueueBoxName = 'sync_queue_box';
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Search
  static const int searchDebounceMs = 300;
  
  // Undo
  static const int undoTimeoutSeconds = 5;
}
