import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveService {
  static final _scopes = [drive.DriveApi.driveFileScope];
  late drive.DriveApi _driveApi;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '820216106036-pkqaumgputna3k34d8a9les7sn5fsuue.apps.googleusercontent.com', // ✅ YOUR WEB CLIENT ID
    scopes: _scopes,
  );

  /// Sign in to Google and prepare the Drive API
  Future<void> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        print("❌ Sign-in aborted by user.");
        return;
      }

      final auth = await account.authentication;
      final authHeaders = {
        'Authorization': 'Bearer ${auth.accessToken}',
        'X-Goog-AuthUser': '0',
      };

      final client = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(client);

      print("✅ Signed in as ${account.email}");
    } catch (e) {
      print("❌ Google Sign-In failed: $e");
    }
  }

  /// Upload JSON string to Google Drive
  Future<void> uploadJson(String fileName, String jsonData) async {
    try {
      final media = drive.Media(
        Stream.value(utf8.encode(jsonData)),
        jsonData.length,
        contentType: 'application/json',
      );

      final file = drive.File()
        ..name = fileName
        ..mimeType = 'application/json';

      final response =
          await _driveApi.files.create(file, uploadMedia: media);
      print("✅ Uploaded file: ${response.name} (ID: ${response.id})");
    } catch (e) {
      print("❌ Failed to upload file: $e");
    }
  }

  /// Download JSON string from Drive by file name
  Future<String?> downloadBackupFile(String fileName) async {
    try {
      final files = await _driveApi.files.list(
        q: "name = '$fileName' and mimeType = 'application/json'",
        spaces: 'drive',
      );

      if (files.files == null || files.files!.isEmpty) {
        print("⚠️ File not found: $fileName");
        return null;
      }

      final fileId = files.files!.first.id;
      if (fileId == null) return null;

      final media = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      final bytes = <int>[];
      await for (final chunk in (media as drive.Media).stream) {
        bytes.addAll(chunk);
      }

      final content = utf8.decode(bytes);
      print("📥 Downloaded content: ${content.substring(0, 50)}...");
      return content;
    } catch (e) {
      print("❌ Failed to download file: $e");
      return null;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
