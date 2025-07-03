import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  // Ganti dengan API Key Gemini Anda yang sebenarnya
  static const String _geminiApiKey = 'AIzaSyBQFMMyQMFf47sajvBssUKsb85FeW8x7OY';

  final GenerativeModel _model = GenerativeModel(
    model:
        'gemini-1.5-flash', // Atau model lain yang relevan seperti 'gemini-pro-vision' jika Anda ingin input gambar
    apiKey: _geminiApiKey,
  );

  final List<Content> _chatHistory = []; // Untuk menyimpan riwayat percakapan3

  ChatbotService() {
    // Anda bisa menambahkan pesan pembuka atau instruksi awal untuk AI di sini
    _chatHistory.add(
      Content.text(
        'Halo! Saya asisten virtual SmartSchool. Ada yang bisa saya bantu?',
      ),
    );
  }

  Future<String> getChatResponse(String userMessage) async {
    // if (_geminiApiKey == 'AIzaSyBQFMMyQMFf47sajvBssUKsb85FeW8x7OY' ||
    //     _geminiApiKey.isEmpty) {
    //   return 'API Key Gemini belum diatur. Silakan tambahkan API Key Anda sekarang.';
    // }

    try {
      // Tambahkan pesan pengguna ke riwayat
      _chatHistory.add(Content.text(userMessage));

      // Kirim seluruh riwayat percakapan untuk mendapatkan respons yang kontekstual
      final response = await _model.generateContent(_chatHistory);

      final String? generatedText = response.text;

      if (generatedText != null) {
        // Tambahkan respons AI ke riwayat
        _chatHistory.add(Content.model([TextPart(generatedText)]));
        return generatedText;
      } else {
        return 'Maaf, saya tidak dapat menghasilkan respons. Mohon coba lagi.';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'Terjadi kesalahan saat menghubungi server AI. Mohon coba lagi nanti.';
    }
  }

  // Anda bisa menambahkan fungsi untuk membersihkan riwayat chat
  void clearChatHistory() {
    _chatHistory.clear();
    _chatHistory.add(
      Content.text(
        'Halo! Saya asisten virtual SmartSchool. Ada yang bisa saya bantu?',
      ),
    );
  }
}
