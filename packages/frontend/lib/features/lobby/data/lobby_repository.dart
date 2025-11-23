import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class LobbyRepository {
  LobbyRepository(this._dio);

  final Dio _dio;

  Future<(Game, Team)> joinGame({
    required String code,
    required String teamName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/games/$code/join',
        data: {'teamName': teamName},
      );

      // Check if response is successful
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data == null) {
          throw Exception('Invalid response from server');
        }

        final gameJson = response.data!['game'] as Map<String, dynamic>?;
        final teamJson = response.data!['team'] as Map<String, dynamic>?;

        if (gameJson == null || teamJson == null) {
          throw Exception('Invalid response format');
        }

        return (Game.fromJson(gameJson), Team.fromJson(teamJson));
      } else {
        // Handle error response
        String errorMessage = 'Failed to join game';

        if (response.data != null && response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          }
        }

        if (response.statusCode == 404) {
          errorMessage =
              'Game code not found. Please check the code and try again.';
        } else if (response.statusCode == 400) {
          errorMessage =
              response.data != null &&
                  response.data is Map<String, dynamic> &&
                  (response.data as Map<String, dynamic>).containsKey('error')
              ? (response.data as Map<String, dynamic>)['error'] as String
              : 'Invalid request. Please check your input.';
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'Failed to join game';

      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('error')) {
          errorMessage = errorData['error'] as String;
        } else if (e.response!.statusCode == 404) {
          errorMessage =
              'Game code not found. Please check the code and try again.';
        } else if (e.response!.statusCode == 400) {
          errorMessage =
              errorData is Map<String, dynamic> &&
                  errorData.containsKey('error')
              ? errorData['error'] as String
              : 'Invalid request. Please check your input.';
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      // Re-throw if it's already an Exception, otherwise wrap it
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to join game: $e');
    }
  }
}
