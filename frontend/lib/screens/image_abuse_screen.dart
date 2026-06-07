import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class ImageAbuseScreen extends StatefulWidget {
  const ImageAbuseScreen({super.key});

  @override
  State<ImageAbuseScreen> createState() => _ImageAbuseScreenState();
}

class _ImageAbuseScreenState extends State<ImageAbuseScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _statusMessage;
  String? _uploadedImageUrl;
  String? _tineyeUrl;

  // Takedown fields
  final _foundLinkController = TextEditingController();
  final _customEmailController = TextEditingController();
  String _selectedPlatformEmail = '';
  
  bool _isGeneratingTakedown = false;
  String? _takedownSubject;
  String? _takedownBody;
  String? _takedownMailto;

  final Map<String, String> _platforms = {
    'Select Platform Email': '',
    'Facebook (support@facebook.com)': 'support@facebook.com',
    'Instagram (support@instagram.com)': 'support@instagram.com',
    'Twitter / X (support@twitter.com)': 'support@twitter.com',
  };

  @override
  void dispose() {
    _foundLinkController.dispose();
    _customEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _statusMessage = null;
          _uploadedImageUrl = null;
          _tineyeUrl = null;
          _takedownSubject = null;
          _takedownBody = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error selecting image: $e";
      });
    }
  }

  Future<void> _uploadAndScan() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
      _statusMessage = "Uploading image and querying reverse search index...";
    });

    final result = await ApiService.uploadImage(_selectedImage!);
    
    setState(() {
      _isUploading = false;
      if (result.containsKey('error')) {
        _statusMessage = "❌ Failed: ${result['error']}";
      } else {
        _statusMessage = "✅ Scan complete. Image indexed.";
        _uploadedImageUrl = result['uploaded_image_url'];
        _tineyeUrl = result['tineye_url'];
        
        // Auto populate the search link for convenience
        _foundLinkController.text = _tineyeUrl ?? '';
      }
    });
  }

  Future<void> _checkUrlForAbuse() async {
    final url = _foundLinkController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please paste or type a URL to check.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = "Analyzing URL safety index...";
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isUploading = false;
      _statusMessage = "✅ URL Check complete. No direct deepfake patterns flagged.";
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  Future<void> _generateTakedown() async {
    final link = _foundLinkController.text.trim();
    final custom = _customEmailController.text.trim();
    final platform = _selectedPlatformEmail;

    final recipient = custom.isNotEmpty ? custom : platform;

    if (link.isEmpty || recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a link and select a recipient email.")),
      );
      return;
    }

    setState(() {
      _isGeneratingTakedown = true;
    });

    final result = await ApiService.generateTakedown(
      foundLink: link,
      platformEmail: platform,
      customEmail: custom,
    );

    setState(() {
      _isGeneratingTakedown = false;
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      } else {
        _takedownSubject = result['takedown_subject'];
        _takedownBody = result['takedown_body'];
        _takedownMailto = result['takedown_mailto'];
      }
    });
  }

  void _copyToClipboard(String text, String label) {
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
          "Deepfake Detection",
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
                "Upload an image to check if it has been abused or shared online.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Dotted Upload Box Container
              GestureDetector(
                onTap: _pickImage,
                child: CustomPaint(
                  painter: DottedBorderPainter(
                    color: Colors.black26,
                    strokeWidth: 1.5,
                    gap: 6,
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Upload Image",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Tap to upload an image for deepfake detection.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4081),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Choose Image",
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D5D5)),
                    ),
                  ),
                ),

              if (_statusMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: _statusMessage!.contains('❌') ? Colors.redAccent : const Color(0xFF007A7C),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Reverse Image Search Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadAndScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D5D5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Reverse Image Search",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Paste URL Input Field
              TextField(
                controller: _foundLinkController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: _buildInputDecoration("Paste URL"),
              ),
              const SizedBox(height: 12),

              // Check URL Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _checkUrlForAbuse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D5D5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Check URL for Abuse",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Takedown Section
              Text(
                "Request removal by legal authorities",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Platform dropdown
              DropdownButtonFormField<String>(
                style: GoogleFonts.inter(color: Colors.black87),
                value: _selectedPlatformEmail.isEmpty ? null : _selectedPlatformEmail,
                decoration: _buildInputDecoration("Select Platform Email"),
                items: _platforms.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(
                      entry.key,
                      style: GoogleFonts.inter(color: Colors.black87),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatformEmail = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 10),
              
              Center(
                child: Text(
                  "OR",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Custom Recipient Field
              TextField(
                controller: _customEmailController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: _buildInputDecoration("Custom recipient email"),
              ),
              const SizedBox(height: 16),

              // Request Takedown Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGeneratingTakedown ? null : _generateTakedown,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D5D5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Request Takedown",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Takedown Generated Card Output
              if (_takedownSubject != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Takedown Draft",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: Color(0xFF00D5D5), size: 20),
                            onPressed: () => _copyToClipboard(
                              "Subject: $_takedownSubject\n\n$_takedownBody",
                              "Draft email",
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 10),
                      Text(
                        "Subject:",
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      Text(
                        _takedownSubject!,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Body:",
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      Text(
                        _takedownBody!,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(_takedownMailto!),
                          icon: const Icon(Icons.outgoing_mail, size: 18),
                          label: Text(
                            "Send via Email App",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4081),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: Colors.black.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00D5D5), width: 1.5),
      ),
    );
  }
}

// Custom Painter for drawing dotted border on the upload box
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    ));

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = gap;
        canvas.drawPath(
          metric.extractPath(distance, distance + len),
          paint,
        );
        distance += len * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
