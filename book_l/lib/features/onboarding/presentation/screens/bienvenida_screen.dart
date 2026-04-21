import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/storage/local_storage.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Aprende a tu ritmo',
      subtitle: 'Lecciones cortas y enfocadas para avanzar cada dia.',
      image: 'assets/images/picstart_1.svg',
      buttonText: 'Siguiente',
    ),
    OnboardingData(
      title: 'Mide tu progreso',
      subtitle: 'Dashboards y evaluaciones para monitorear tus avances.',
      image: 'assets/images/picstart_2.svg',
      buttonText: 'Comenzar',
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    AppSession().setOnboardingCompleted(true);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Omitir',
                    style: TextStyle(
                      color: Color(0x99000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                width: 156,
                height: 49,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xCC4DC130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _pages[_currentPage].buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SvgPicture.asset(
                  data.image,
                  height: MediaQuery.of(context).size.height * 0.35,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xCC000000),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                data.subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0x99000000),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 13,
      width: 13,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF4DC130)
            : const Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
  });
}
