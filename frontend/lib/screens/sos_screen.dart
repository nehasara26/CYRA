import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SOSScreen extends StatefulWidget {
  final bool immediateTrigger;
  const SOSScreen({super.key, this.immediateTrigger = false});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  // Config toggles
  bool _sendLiveLocation = true;
  bool _triggerFakeCall = true;

  // SOS activation state
  bool _sosCountdownActive = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  // Active overlays
  bool _showIncomingCallBanner = false;
  bool _showCallSimulator = false;
  bool _showConfirmCutDialog = false;

  // Call Duration
  int _callDuration = 0;
  Timer? _callTimer;

  // Contacts
  String _contactName = "Mom";
  String _contactPhone = "+1 (555) 019-2834";
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.immediateTrigger) {
      _triggerSOS();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _callTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _triggerSOS() {
    if (_sosCountdownActive) return;

    setState(() {
      _sosCountdownActive = true;
      _countdown = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _sosCountdownActive = false;
        });
        _onSOSActivated();
      }
    });
  }

  void _cancelSOS() {
    _countdownTimer?.cancel();
    setState(() {
      _sosCountdownActive = false;
    });
  }

  void _onSOSActivated() {
    if (_triggerFakeCall) {
      // Show incoming call banner overlay at the top
      setState(() {
        _showIncomingCallBanner = true;
      });
    } else {
      // Standard SMS dispatch notification
      _showMockAlertSent();
    }
  }

  void _showMockAlertSent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "SOS Dispatched",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFFF512F)),
        ),
        content: Text(
          "Emergency notification sent to $_contactName.\nLocation coordinates (Lat 37.7749, Lon -122.4194) and SOS link dispatched.",
          style: GoogleFonts.inter(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF00D5D5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Call Simulation ---
  void _acceptFakeCall() {
    setState(() {
      _showIncomingCallBanner = false;
      _showCallSimulator = true;
      _callDuration = 0;
    });

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  void _declineFakeCall() {
    setState(() {
      _showIncomingCallBanner = false;
    });
  }

  void _hangupCall() {
    setState(() {
      _showConfirmCutDialog = true;
    });
  }

  void _confirmHangup(bool endCall) {
    setState(() {
      _showConfirmCutDialog = false;
    });
    if (endCall) {
      _callTimer?.cancel();
      setState(() {
        _showCallSimulator = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return "$minutes:${remaining.toString().padLeft(2, '0')}";
  }

  void _showEditContactDialog() {
    _nameController.text = _contactName;
    _phoneController.text = _contactPhone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Emergency Contact",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E1E24)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Contact Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contactName = _nameController.text.trim();
                _contactPhone = _phoneController.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D5D5)),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCallSimulator) {
      return _buildCallSimulatorScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Base SOS Panel
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back / Title Header
                  Row(
                    children: [
                      const BackButton(color: Colors.black87),
                      Text(
                        "SOS",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1E24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Map panel
                  _buildMockMapCard(),
                  const SizedBox(height: 20),

                  // Contact Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Contact Details",
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E1E24),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$_contactName ($_contactPhone)",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black54),
                          onPressed: _showEditContactDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Toggles
                  _buildToggleRow(
                    title: "Send Live location",
                    value: _sendLiveLocation,
                    onChanged: (val) => setState(() => _sendLiveLocation = val),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleRow(
                    title: "Trigger a fake call",
                    value: _triggerFakeCall,
                    onChanged: (val) => setState(() => _triggerFakeCall = val),
                  ),

                  const SizedBox(height: 35),
                  
                  // Countdown overlay indicator
                  if (_sosCountdownActive) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF512F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$_countdown",
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF512F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "SOS Countdown Active. Press cancel to abort.",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _cancelSOS,
                        child: const Text("CANCEL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    // Press SOS details
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Press SOS button below to activate",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black38),
                          // Custom button inside screen as trigger too
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _triggerSOS,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF512F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                            child: const Text("Trigger Test SOS"),
                          )
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Top Incoming Call Banner Popup
            if (_showIncomingCallBanner)
              Positioned(
                top: 10,
                left: 15,
                right: 15,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF333333),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Incoming Call",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _contactName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.phone_in_talk, color: Colors.greenAccent),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _declineFakeCall,
                              child: const Text(
                                "Decline",
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: _acceptFakeCall,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Accept"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00D5D5),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMapCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.08),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Stack(
        children: [
          // Mock Map Roads Graphic (Custom drawing via Canvas/CustomPainter or simply beautiful icons)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: MapGridPainter(),
              ),
            ),
          ),
          
          // Marker Pin in Center
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.red,
                  size: 40,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          
          // Current location tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Text(
                "Current Location",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Call Screen Simulator Widget ---
  Widget _buildCallSimulatorScreen() {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF1C1B1F),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tab Labels
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCallTab("RECENT"),
                      _buildCallTab("CONTACTS"),
                      _buildCallTab("FAVOURITE"),
                    ],
                  ),
                ),

                // Center Calling Profile Section
                Column(
                  children: [
                    // Avatar image placeholder
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, size: 60, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _contactName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "CALLING • ${_formatDuration(_callDuration)}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                // Control panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCallIcon(Icons.volume_up, "Speaker"),
                          _buildCallIcon(Icons.pause, "Hold"),
                          _buildCallIcon(Icons.dialpad, "Keypad"),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCallIcon(Icons.videocam_rounded, "Video"),
                          _buildCallIcon(Icons.add_call, "Add call"),
                          _buildCallIcon(Icons.mic, "Mute"),
                        ],
                      ),
                    ],
                  ),
                ),

                // End Call Red Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: _hangupCall,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Center(
                          child: Icon(Icons.call_end, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Confirm End Call Overlay Dialog
        if (_showConfirmCutDialog)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2D32),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Are you sure you want to end the call?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _confirmHangup(true),
                              child: const Text("Yes", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Container(width: 1, height: 20, color: Colors.white24),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _confirmHangup(false),
                              child: const Text("No", style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCallTab(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: Colors.white38,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCallIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white30)),
      ],
    );
  }
}

// Custom Painter to draw a mock map grid
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 2;

    // Draw grid/roads
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), paint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.35, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.6, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
