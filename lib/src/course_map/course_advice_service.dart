import 'dart:convert';
import 'dart:io';

class CourseAdviceService {
  CourseAdviceService._();

  static final CourseAdviceService instance = CourseAdviceService._();

  static const String _endpoint =
      'https://ark.cn-beijing.volces.com/api/v3/responses';
  static const String _apiKey =
      'ark-54982976-2cdc-4bbb-9181-be32d3a987b2-781fd';
  static const String _model = 'doubao-seed-2-0-mini-260215';

  final Map<String, List<String>> _cache = <String, List<String>>{};

  Future<List<String>> fetchSuggestions({
    required String title,
    required String subtitle,
    required String description,
  }) async {
    final cacheKey = '$title|$subtitle|$description';
    final cached = _cache[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final suggestions = await _requestSuggestions(
      title: title,
      subtitle: subtitle,
      description: description,
    );
    _cache[cacheKey] = suggestions;
    return suggestions;
  }

  Future<List<String>> _requestSuggestions({
    required String title,
    required String subtitle,
    required String description,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_apiKey');

      final prompt = '''
你是一名手语课程动作建议助手。
请根据课程词语、课程标签和基础动作描述，为初学者生成 2 到 3 条动作建议。

要求：
1. 每条建议都必须是完整、自然、可直接练习的中文句子。
2. 只聚焦手形、位置、节奏、镜头距离、稳定性这些动作层面的改进。
3. 不要复述用户请求，不要解释你的思考过程，不要输出“我需要分析”“用户要求我”“作为助手”这类话。
4. 不要输出“建议1”“建议2”这类占位词。
5. 只返回 JSON，格式必须是：
{"suggestions":["第一条真实建议","第二条真实建议"]}

课程词语：$title
课程标签：$subtitle
基础动作：$description
''';

      final payload = jsonEncode(<String, Object>{
        'model': _model,
        'input': <Map<String, Object>>[
          <String, Object>{
            'role': 'user',
            'content': <Map<String, String>>[
              <String, String>{
                'type': 'input_text',
                'text': prompt,
              },
            ],
          },
        ],
      });

      final payloadBytes = utf8.encode(payload);
      request.contentLength = payloadBytes.length;
      request.add(payloadBytes);

      final response = await request.close().timeout(const Duration(seconds: 20));
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          '豆包 API ${response.statusCode}: ${_extractErrorMessage(body)}',
        );
      }

      final suggestions = _extractSuggestions(body);
      if (suggestions.isEmpty) {
        throw const FormatException('豆包没有返回有效建议');
      }
      return suggestions.take(3).toList();
    } finally {
      client.close(force: true);
    }
  }

  List<String> _extractSuggestions(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('豆包返回结构异常');
    }

    final outputText = _extractOutputText(decoded).trim();
    if (outputText.isEmpty) {
      throw const FormatException('豆包没有返回文本内容');
    }

    final parsedJson = _tryParseSuggestionsJson(outputText);
    if (parsedJson.isNotEmpty) {
      return parsedJson;
    }

    if (_containsMetaResponse(outputText)) {
      throw const FormatException('豆包返回了分析过程');
    }

    final splitSuggestions = _splitSuggestions(outputText);
    if (splitSuggestions.isEmpty) {
      throw const FormatException('豆包返回内容无法解析为建议');
    }
    return splitSuggestions;
  }

  String _extractOutputText(Map<String, dynamic> decoded) {
    final directOutputText = decoded['output_text'];
    if (directOutputText is String && directOutputText.trim().isNotEmpty) {
      return directOutputText.trim();
    }

    final output = decoded['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final content = item['content'];
        if (content is! List) {
          continue;
        }
        for (final block in content) {
          if (block is! Map<String, dynamic>) {
            continue;
          }
          final text = block['text'];
          if (text is String && text.trim().isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            buffer.write(text.trim());
          }
        }
      }
      if (buffer.isNotEmpty) {
        return buffer.toString();
      }
    }

    final choices = decoded['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map<String, dynamic>) {
        final message = first['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is String && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      }
    }

    return '';
  }

  List<String> _tryParseSuggestionsJson(String text) {
    final normalized = text
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
        .trim();

    final direct = _extractSuggestionsFromJsonString(normalized);
    if (direct.isNotEmpty) {
      return direct;
    }

    final match = RegExp(r'\{[\s\S]*"suggestions"[\s\S]*\}')
        .firstMatch(normalized);
    if (match == null) {
      return const [];
    }

    return _extractSuggestionsFromJsonString(match.group(0)!);
  }

  List<String> _extractSuggestionsFromJsonString(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        final suggestions = decoded['suggestions'];
        if (suggestions is List) {
          return _normalizeSuggestions(suggestions);
        }
      }
      if (decoded is List) {
        return _normalizeSuggestions(decoded);
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  List<String> _splitSuggestions(String text) {
    final rawLines = text.replaceAll('\r', '').split('\n');
    final suggestions = <String>[];

    for (final line in rawLines) {
      final cleaned = _cleanSuggestion(line);
      if (cleaned.isNotEmpty &&
          !_isPlaceholderSuggestion(cleaned) &&
          !_isMetaSuggestion(cleaned) &&
          !suggestions.contains(cleaned)) {
        suggestions.add(cleaned);
      }
    }

    if (suggestions.length <= 1 && suggestions.isNotEmpty) {
      final parts = suggestions.first
          .split(RegExp('[;\\uFF1B]'))
          .map(_cleanSuggestion)
          .where((item) => item.isNotEmpty)
          .where((item) => !_isPlaceholderSuggestion(item))
          .where((item) => !_isMetaSuggestion(item))
          .toList();
      if (parts.length > 1) {
        return parts;
      }
    }

    return suggestions;
  }

  List<String> _normalizeSuggestions(List<dynamic> items) {
    final suggestions = <String>[];
    for (final item in items) {
      final cleaned = _cleanSuggestion(item?.toString() ?? '');
      if (cleaned.isNotEmpty &&
          !_isPlaceholderSuggestion(cleaned) &&
          !_isMetaSuggestion(cleaned) &&
          !suggestions.contains(cleaned)) {
        suggestions.add(cleaned);
      }
    }
    return suggestions;
  }

  bool _containsMetaResponse(String text) {
    final normalized = text.replaceAll(' ', '');
    return normalized.contains('我需要分析这个请求') ||
        normalized.contains('用户要求我') ||
        normalized.contains('作为手语课程动作建议助手') ||
        normalized.contains('需要根据课程词语') ||
        normalized.contains('基础动作描述') ||
        normalized.contains('只返回json') ||
        normalized.contains('不要输出');
  }

  bool _isPlaceholderSuggestion(String value) {
    final normalized = value.trim().replaceAll(' ', '');
    return RegExp(r'^(动作)?建议\d+$').hasMatch(normalized) ||
        normalized == '建议' ||
        normalized == '动作建议' ||
        normalized == '第一条真实建议' ||
        normalized == '第二条真实建议';
  }

  bool _isMetaSuggestion(String value) {
    final normalized = value.trim().replaceAll(' ', '');
    return normalized.startsWith('我需要分析这个请求') ||
        normalized.startsWith('用户要求我') ||
        normalized.startsWith('需要根据课程词语') ||
        normalized.contains('作为手语课程动作建议助手') ||
        normalized.contains('只返回json') ||
        normalized.contains('基础动作描述');
  }

  String _cleanSuggestion(String value) {
    return value
        .trim()
        .replaceAll(RegExp('^[-\\u2022*]\\s*'), '')
        .replaceAll(RegExp('^\\d+\\s*[.)\\u3001:\\uFF1A-]\\s*'), '')
        .replaceAll(RegExp("^[\"']+|[\"']+\$"), '')
        .trim();
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Ignore parse failures and fall back to raw body.
    }

    final trimmed = body.trim();
    return trimmed.isEmpty ? '未知错误' : trimmed;
  }
}
