import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'stalkerware_scanner_screen.dart';
import 'image_abuse_screen.dart';
import 'privacy_toolkit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hello Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sun, 1 June 2025",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hello, Divya!",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1E24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.black54, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Title Section
              Text(
                "Explore Key Safety Tools",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007A7C),
                ),
              ),
              const SizedBox(height: 20),

              // Tool Cards Stack
              Column(
                children: [
                  // 1. Stalkerware Detector
                  _buildToolCard(
                    context: context,
                    moduleTitle: "Stalkerware Detector",
                    title: "Scan for hidden threats",
                    description: "Detect apps that track your location, messages, or calls without your consent.",
                    illustrationColor: const Color(0xFFFFDAB9),
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFFE76F51),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StalkerwareScannerScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 2. Deepfake Detector
                  _buildToolCard(
                    context: context,
                    moduleTitle: "Deepfake Detector",
                    title: "Verify media authenticity",
                    description: "Analyze images and videos to identify potential deepfakes and manipulated content.",
                    illustrationColor: const Color(0xFFFFC0CB),
                    icon: Icons.face_rounded,
                    iconColor: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ImageAbuseScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // 3. Privacy Toolkit
                  _buildToolCard(
                    context: context,
                    moduleTitle: "Privacy Toolkit",
                    title: "Manage your digital footprint",
                    description: "Access tools and resources to enhance your privacy settings and control your data.",
                    illustrationColor: const Color(0xFF1E3A3A),
                    icon: Icons.shield_rounded,
                    iconColor: const Color(0xFFFFD700),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyToolkitScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required String moduleTitle,
    required String title,
    required String description,
    required Color illustrationColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            // Left Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00B2B2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // Right Illustration Container
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: illustrationColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 38,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
