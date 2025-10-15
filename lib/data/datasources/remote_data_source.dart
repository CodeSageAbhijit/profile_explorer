import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class RemoteDataSource {
  static const String baseUrl = 'https://randomuser.me/api/?results=20';
  static const Duration timeout = Duration(seconds: 15);

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] == null) {
          throw const FormatException('Invalid API response format');
        }
        
        final List results = data['results'];
        return results.map((json) => UserModel.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw RateLimitException('Too many requests. Please try again later.');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error. Please try again later.');
      } else {
        throw HttpException('Failed to load users: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw NetworkException('Connection timeout. Please try again.');
    } on FormatException catch (e) {
      throw DataParseException('Failed to parse response: ${e.message}');
    } on http.ClientException {
      throw NetworkException('Network error. Please check your connection.');
    } catch (e) {
      throw UnknownException('An unexpected error occurred: $e');
    }
  }
}

// Custom exception classes
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  @override
  String toString() => message;
}

class DataParseException implements Exception {
  final String message;
  DataParseException(this.message);
  @override
  String toString() => message;
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
  @override
  String toString() => message;
}
