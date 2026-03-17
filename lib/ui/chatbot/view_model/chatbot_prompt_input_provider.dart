import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatbot_prompt_input_provider.g.dart';

@riverpod
class ChatbotPromptInput extends _$ChatbotPromptInput {
  @override
  String build() => '';

  void setInput(String value) => state = value;

  void clear() => state = '';
}
