import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class StalkerwareScannerScreen extends StatefulWidget {
  const StalkerwareScannerScreen({super.key});

  @override
  State<StalkerwareScannerScreen> createState() => _StalkerwareScannerScreenState();
}

class _StalkerwareScannerScreenState extends State<StalkerwareScannerScreen> {
  bool _isScanning = false;
  
  List<String> _stalkerwareDetected = [];
  List<Map<String, dynamic>> _installedApps = [];
  String _message = "";

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    // Simulate standard scanning duration for micro-interaction
    await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

    // Fetch details from Django backend
    final stalkerwareResult = await ApiService.flagStalkerware();
    final permissionsResult = await ApiService.getPermissions();

    if (mounted) {
      setState(() {
        _stalkerwareDetected = List<String>.from(stalkerwareResult['stalkerware_detected'] ?? []);
        _message = stalkerwareResult['message'] ?? "Scan finished.";
        _installedApps = permissionsResult;
        _isScanning = false;
      });
    }
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
          "Stalkerware",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isScanning
            ? _buildScanningView()
            : _buildResultsView(),
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D5D5)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Scanning apps & permissions...",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Analyzing with Cyra AI engine",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Installed Apps Container Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    "Installed Apps",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                
                // List of apps
                if (_installedApps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No apps detected",
                        style: GoogleFonts.inter(color: Colors.black54),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _installedApps.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final appData = _installedApps[index];
                      final String appName = appData['app'] ?? 'Unknown App';
                      final List permissions = appData['permissions'] ?? [];
                      final String permsString = permissions.join(', ');
                      final bool isRisk = _stalkerwareDetected.contains(appName);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isRisk 
                                ? const Color(0xFFFF4081).withOpacity(0.08) 
                                : const Color(0xFF00D5D5).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRisk ? Icons.shield_outlined : Icons.verified_user_outlined,
                            color: isRisk ? const Color(0xFFFF4081) : const Color(0xFF00D5D5),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          appName,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Permissions: $permsString",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.black38,
                          size: 22,
                        ),
                        onTap: () {
                          // Handle details view if needed
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Risk Summary Section
          Text(
            "Risk Summary",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          
          Text(
            _message.isNotEmpty
                ? _message
                : "No threats or high-risk permissions detected on this device.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),

          // Scan Again Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D5D5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Scan Again",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
