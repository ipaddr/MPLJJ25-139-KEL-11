import 'package:flutter/material.dart';
import 'package:smartschool/utils/app_router.dart';
import 'package:smartschool/utils/app_constants.dart'; // Untuk warna

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/onboarding1.png', // Tambahkan gambar
      'title': 'Sekolah Unggul',
      'description':
          'Temukan sekolah unggulan dan informasi lengkap fasilitas pendidikan.',
    },
    {
      'image': 'assets/images/onboarding2.png', // Tambahkan gambar
      'title': 'Manajemen yang Efisien',
      'description':
          'Kelola menu makan siang dan pantau infrastruktur sekolah dengan mudah.',
    },
    {
      'image': 'assets/images/onboarding3.png', // Tambahkan gambar
      'title': 'Akses Mudah & Cerdas',
      'description':
          'Portal untuk siswa, guru, orang tua, dan bantuan chatbot AI.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: _onboardingData[index]['image']!,
                title: _onboardingData[index]['title']!,
                description: _onboardingData[index]['description']!,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.authRoute,
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Mulai Sekarang'
                            : 'Selanjutnya',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (_currentPage != _onboardingData.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.authRoute,
                        );
                      },
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppConstants.primaryBlue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 24 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? AppConstants.primaryBlue : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppConstants.darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
