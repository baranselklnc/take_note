import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ServerDiscoveryService {
  static final Logger _logger = Logger();
  static String? _discoveredBaseUrl;
  static bool _isInitialized = false;

 
  static String get baseUrl => _discoveredBaseUrl ?? 'http://localhost:8000';


  static bool get isInitialized => _isInitialized;

  
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.i('🔍 Starting server discovery...');
      
     
      if (await _tryConnection('http://localhost:8000')) {
        _discoveredBaseUrl = 'http://localhost:8000';
        _logger.i('✅ Server found at localhost:8000');
        _isInitialized = true;
        return;
      }

      
      if (await _tryConnection('http://127.0.0.1:8000')) {
        _discoveredBaseUrl = 'http://127.0.0.1:8000';
        _logger.i('✅ Server found at 127.0.0.1:8000');
        _isInitialized = true;
        return;
      }

      final serverInfo = await _getServerInfoFromLocalhost();
      if (serverInfo != null) {
        _discoveredBaseUrl = serverInfo['base_url'];
        _logger.i('✅ Server found via server-info: $_discoveredBaseUrl');
        _isInitialized = true;
        return;
      }

      final discoveredUrl = await _tryCommonIPs();
      if (discoveredUrl != null) {
        _discoveredBaseUrl = discoveredUrl;
        _logger.i('✅ Server found via IP discovery: $_discoveredBaseUrl');
        _isInitialized = true;
        return;
      }

      _discoveredBaseUrl = 'http://localhost:8000';
      _logger.w('⚠️ Server discovery failed, using fallback: $_discoveredBaseUrl');
      _isInitialized = true;

    } catch (e) {
      _logger.e('❌ Server discovery error: $e');
      _discoveredBaseUrl = 'http://localhost:8000';
      _isInitialized = true;
    }
  }

  
  static Future<bool> _tryConnection(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$url/health',
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

   
  static Future<Map<String, dynamic>?> _getServerInfoFromLocalhost() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:8000/server-info',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      _logger.d('Localhost server-info failed: $e');
    }
    return null;
  }

  static Future<String?> _tryCommonIPs() async {
    // Common IP ranges to try
    final commonIPs = [
      '192.168.1.100',  
      '192.168.0.100',
      '192.168.1.1',
      '192.168.0.1',
      '10.0.0.100',
      '10.0.2.2',       // Android emulator host
    ];

    for (final ip in commonIPs) {
      try {
        final url = 'http://$ip:8000';
        if (await _tryConnection(url)) {
          return url;
        }
      } catch (e) {
        _logger.d('Trying $ip:8000... Failed');
      }
    }

    return null;
  }

  static void reset() {
    _discoveredBaseUrl = null;
    _isInitialized = false;
  }

  static Future<Map<String, dynamic>?> getServerInfo() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl/server-info');
      
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      _logger.e('Failed to get server info: $e');
    }
    
    return null;
  }

  static Future<bool> isConnectionWorking() async {
    if (!_isInitialized) {
      await initialize();
    }

    return await _tryConnection(baseUrl);
  }

  static Future<void> retryDiscovery() async {
    reset();
    await initialize();
  }
}
