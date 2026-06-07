import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'stalkerware_scanner_screen.dart';

class PrivacyToolkitScreen extends StatefulWidget {
  const PrivacyToolkitScreen({super.key});

  @override
  State<PrivacyToolkitScreen> createState() => _PrivacyToolkitScreenState();
}

class _PrivacyToolkitScreenState extends State<PrivacyToolkitScreen> {
  // Password Generator State
  String _generatedPassword = "";
  bool _isGenerating = false;
  double _passwordLength = 12;

  // Social Tips State
  List<String> _socialTips = [];
  bool _isLoadingTips = false;

  @override
  void initState() {
    super.initState();
    _loadSocialTips();
  }

  Future<void> _loadSocialTips() async {
    setState(() {
      _isLoadingTips = true;
    });
    final tips = await ApiService.getSocialTips();
    setState(() {
      _socialTips = tips;
      _isLoadingTips = false;
    });
  }

  Future<void> _generatePassword() async {
    setState(() {
      _isGenerating = true;
    });
    final password = await ApiService.generatePassword();
    setState(() {
      _generatedPassword = password;
      _isGenerating = false;
    });
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy Toolkit",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Secure your data. Take control of your digital presence.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),

              // Card 1: Revoke App Permissions
              _buildToolkitCard(
                title: "Revoke App Permissions",
                description: "Scan to identify apps with risky permissions and manage dangerous/excessive app permissions.",
                buttonText: "Scan",
                illustrationColor: const Color(0xFFFFB399),
                icon: Icons.phonelink_lock_rounded,
                iconColor: const Color(0xFFE76F51),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StalkerwareScannerScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Card 2: Social Profile Lockdown Guide
              _buildToolkitCard(
                title: "Social Profile Lockdown Guide",
                description: "Open guide for step-by-step instructions to secure accounts on platforms like Instagram/Facebook.",
                buttonText: "Open Guide",
                illustrationColor: const Color(0xFF4A6572),
                icon: Icons.shield_outlined,
                iconColor: Colors.white,
                onTap: () => _showLockdownGuideSheet(context),
              ),
              const SizedBox(height: 18),

              // Card 3: Strong Password Generator
              _buildToolkitCard(
                title: "Strong Password Generator",
                description: "Generate secure passwords and securely store them for enhanced online security.",
                buttonText: "Generate",
                illustrationColor: const Color(0xFFA5D6A7),
                icon: Icons.vpn_key_outlined,
                iconColor: const Color(0xFF2E7D32),
                onTap: () => _showPasswordGeneratorSheet(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolkitCard({
    required String title,
    required String description,
    required String buttonText,
    required Color illustrationColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black87),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),

          // Right graphic
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
    );
  }

  // Bottom sheet modal for Social Profile Lockdown Guide
  void _showLockdownGuideSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Social Profile Lockdown Guide",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Ensure your profiles are locked down and secure from tracking.",
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 15),
                      const Divider(height: 1),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _isLoadingTips
                            ? const Center(child: CircularProgressIndicator())
                            : _socialTips.isEmpty
                                ? Center(
                                    child: Text(
                                      "No guides available at this time.",
                                      style: GoogleFonts.inter(color: Colors.black38),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: _socialTips.length,
                                    itemBuilder: (context, index) {
                                      final tip = _socialTips[index];
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF00D5D5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                "${index + 1}",
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                tip,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Bottom sheet modal for Strong Password Generator
  void _showPasswordGeneratorSheet(BuildContext context) {
    _generatedPassword = ""; // reset password when opening
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Strong Password Generator",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Generate random secure passwords to protect your online accounts.",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Display Area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SelectableText(
                            _generatedPassword.isEmpty
                                ? "Click Generate below"
                                : _generatedPassword,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _generatedPassword.isEmpty
                                  ? Colors.black38
                                  : const Color(0xFF007A7C),
                            ),
                          ),
                        ),
                        if (_generatedPassword.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: Color(0xFF00D5D5)),
                            onPressed: () => _copyToClipboard(_generatedPassword, "Password"),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Slider details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Length",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "${_passwordLength.toInt()} characters",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00D5D5),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _passwordLength,
                    min: 8,
                    max: 24,
                    activeColor: const Color(0xFF00D5D5),
                    inactiveColor: Colors.black.withOpacity(0.05),
                    onChanged: (value) {
                      setSheetState(() {
                        _passwordLength = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isGenerating
                          ? null
                          : () async {
                              setSheetState(() {
                                _isGenerating = true;
                              });
                              await _generatePassword();
                              setSheetState(() {});
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D5D5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isGenerating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "Generate Password",
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
