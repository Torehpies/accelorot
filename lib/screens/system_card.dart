import 'package:flutter/material.dart';

class SystemCard extends StatefulWidget {
  const SystemCard({super.key});

  @override
  State<SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<SystemCard> {
  String status = "Excellent"; // can be "Excellent", "Warning", "Error"
  String selectedPeriod = "1 hour";
  String selectedCycle = "100"; // default cycle
  bool isRunning = false; // tracks if Start was pressed
  bool isPaused = false; // tracks Pause state

  // Status color & icon
  Color getStatusColor() {
    switch (status) {
      case "Excellent":
        return Colors.green;
      case "Warning":
        return Colors.orange;
      case "Error":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case "Excellent":
        return Icons.check_circle;
      case "Warning":
        return Icons.warning;
      case "Error":
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
                // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'System',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Status: ',
                      style: TextStyle(color: Colors.black54)),
                  Text(
                    status,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(getStatusIcon(), color: getStatusColor(), size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Uptime and Last Update info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Uptime\n12:12:12',
                style: TextStyle(color: Colors.black87),
              ),
              Text(
                'Last Update\n12:12:13 Aug 30, 2025',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Drum Rotation Label
          const Text(
            'Drum Rotation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // Inputs row
          Row(
            children: [
              // Cycle choices dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Set number of Cycles',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  initialValue: selectedCycle,
                  onChanged: (value) {
                    setState(() => selectedCycle = value!);
                  },
                  items: const [
                    DropdownMenuItem(value: "50", child: Text("50")),
                    DropdownMenuItem(value: "100", child: Text("100")),
                    DropdownMenuItem(value: "150", child: Text("150")),
                    DropdownMenuItem(value: "200", child: Text("200")),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Period dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Set Period',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  initialValue: selectedPeriod,
                  onChanged: (value) {
                    setState(() => selectedPeriod = value!);
                  },
                  items: const [
                    DropdownMenuItem(value: '1 hour', child: Text('1 hour')),
                    DropdownMenuItem(
                        value: '12 hours', child: Text('12 hours')),
                    DropdownMenuItem(
                        value: '24 hours', child: Text('24 hours')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          Center(
            child: isRunning
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPaused = !isPaused;
                            status = isPaused ? "Warning" : "Excellent";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPaused ? const Color.fromARGB(255, 14, 138, 255) : const Color.fromARGB(255, 255, 185, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                        ),
                        child: Text(
                          isPaused ? "Resume" : "Pause",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRunning = false;
                            isPaused = false;
                            status = "Excellent";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                        ),
                        child: const Text(
                          "Stop",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isRunning = true;
                        status = "Excellent";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5339), // deep green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
