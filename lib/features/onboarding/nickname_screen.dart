import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/storage/progress_store.dart';
import 'flower_rumi_screen.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key, this.store = const ProgressStore()});

  final ProgressStore store;

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _nicknameController = TextEditingController();
  final _focusNode = FocusNode();

  bool get _isNicknameValid {
    final length = _nicknameController.text.trim().characters.length;
    return length >= 2 && length <= 8;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _continueAdventure() async {
    if (!_isNicknameValid) {
      return;
    }
    FocusScope.of(context).unfocus();
    final nickname = _nicknameController.text.trim();
    await widget.store.saveNickname(nickname);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => FlowerRumiScreen(nickname: nickname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GardenBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFE8D9F4),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26715A94),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _WelcomeIcon(),
                          const SizedBox(height: 24),
                          const Text(
                            '별지기님을 만나서 반가워요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF3F2D62),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '별정원에서 사용할 이름을 알려주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF766A85),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _nicknameController,
                            focusNode: _focusNode,
                            autofocus: true,
                            maxLength: 8,
                            textAlign: TextAlign.center,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            ],
                            style: const TextStyle(
                              color: Color(0xFF3F2D62),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: '닉네임 입력',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB7AFC0),
                                fontWeight: FontWeight.w500,
                              ),
                              counterText: '2~8자',
                              counterStyle: const TextStyle(
                                color: Color(0xFF8A7F94),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F3FC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDFD1EC),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8C72D9),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) {
                              _continueAdventure();
                            },
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _isNicknameValid
                                  ? _continueAdventure
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7657B5),
                                disabledBackgroundColor: const Color(0xFFE4DDEB),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: const Color(0xFFAAA1B2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              child: const Text('별지기 시작하기'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '나중에 언제든 바꿀 수 있어요.',
                            style: TextStyle(
                              color: Color(0xFF978DA0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeIcon extends StatelessWidget {
  const _WelcomeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4B8), Color(0xFFF4B8D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4DF2B4C9),
            blurRadius: 22,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Color(0xFF7657B5),
        size: 38,
        semanticLabel: '반짝이는 별',
      ),
    );
  }
}

class _GardenBackground extends StatelessWidget {
  const _GardenBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E9FF),
            Color(0xFFFFF5F3),
            Color(0xFFE9F3EC),
          ],
        ),
      ),
    );
  }
}
