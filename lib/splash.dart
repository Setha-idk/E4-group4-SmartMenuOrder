import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_project/consent/colors.dart';
import 'package:group_project/consent/navigation.dart';
import 'package:group_project/providers/get_provider.dart';

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState<Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash> {
  Future<Widget> fetchInitialData() async {
    try {
      await Future.wait([
        ref.read(mealsProvider.future),
        ref.read(categoriesProvider.future),
        Future.delayed(const Duration(seconds: 4)),
      ]);

      return const Navigation();
    } catch (e) {
      debugPrint("Error fetching data: $e");
      await Future.delayed(const Duration(seconds: 2));
      return Navigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: const Image(image: AssetImage('images/icon.png')),
      title: const Text(
        'Welcome to my\nRecipe Finder\nApp',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 208, 1),
          fontFamily: 'ro',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: background,
      showLoader: true,
      loaderColor: Colors.pink,
      futureNavigator: fetchInitialData(),
    );
  }
}
