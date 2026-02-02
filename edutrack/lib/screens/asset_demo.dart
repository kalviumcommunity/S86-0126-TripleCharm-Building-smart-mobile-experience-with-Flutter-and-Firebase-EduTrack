import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AssetDemo extends StatelessWidget {
  const AssetDemo({super.key});

  // Helper to check whether an asset exists by attempting to load it from assets
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets Demo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Local image (add assets/images/logo.png to project)
              FutureBuilder<bool>(
                future: _assetExists('assets/images/logo.png'),
                builder: (context, snapshot) {
                  final hasAsset = snapshot.data == true;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(width: 140, height: 140, child: Center(child: CircularProgressIndicator()));
                  }

                  return hasAsset
                      ? Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(Icons.school, size: 64, color: Colors.blueGrey),
                        );
                },
              ),

              const SizedBox(height: 20),
              const Text('Powered by EduTrack', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Row of built-in icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.flutter_dash, color: Colors.blue, size: 40),
                  SizedBox(width: 12),
                  Icon(Icons.android, color: Colors.green, size: 40),
                  SizedBox(width: 12),
                  Icon(Icons.apple, color: Colors.grey, size: 40),
                ],
              ),

              const SizedBox(height: 24),

              // Background image example (assets/images/background.png)
              FutureBuilder<bool>(
                future: _assetExists('assets/images/background.png'),
                builder: (context, snapshot) {
                  final hasAsset = snapshot.data == true;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SizedBox(width: double.infinity, height: 160, child: Center(child: CircularProgressIndicator()));
                  }

                  if (hasAsset) {
                    return Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Background Image', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(child: Text('No background asset found', style: TextStyle(color: Colors.black54))),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Guidance note
              const Text(
                'Place your images in assets/images/ and icons in assets/icons/.\nRun `flutter pub get` after adding assets.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
