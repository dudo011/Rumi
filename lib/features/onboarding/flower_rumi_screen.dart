import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class FlowerRumiScreen extends StatelessWidget {
  const FlowerRumiScreen({required this.nickname, super.key});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3FA), Color(0xFFEAF7EA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const Text(
                      '첫 번째 만남',
                      style: TextStyle(
                        color: Color(0xFF8A6A98),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _FlowerRumiAvatar(),
                    const SizedBox(height: 32),
                    Text(
                      '$nickname 별지기님, 안녕!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF3E3156),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '나는 꽃숲을 돌보는 꽃루미야.\n네가 용기를 낼 때마다 우리 정원에 꽃이 피어날 거야!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF70657C),
                        fontSize: 17,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite_rounded),
                        label: const Text('꽃루미와 함께하기'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6F5BA7),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowerRumiAvatar extends StatelessWidget {
  const _FlowerRumiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFDCEB),
        boxShadow: [
          BoxShadow(color: Color(0x4DF3AFCB), blurRadius: 38, spreadRadius: 8),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.local_florist_rounded,
            size: 112,
            color: Color(0xFF76539B),
            semanticLabel: '꽃루미',
          ),
          Positioned(
            left: 53,
            top: 80,
            child: CircleAvatar(radius: 5, backgroundColor: Color(0xFF46344F)),
          ),
          Positioned(
            right: 53,
            top: 80,
            child: CircleAvatar(radius: 5, backgroundColor: Color(0xFF46344F)),
          ),
        ],
      ),
    );
  }
}
