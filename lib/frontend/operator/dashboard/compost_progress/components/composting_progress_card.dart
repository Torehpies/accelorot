import 'package:flutter/material.dart';
import 'batch_id_dialog.dart';
import 'compost_batch_detail_dialog.dart';

class CompostingProgressCard extends StatefulWidget {
  const CompostingProgressCard({super.key});

  @override
  State<CompostingProgressCard> createState() => _CompostingProgressCardState();
}

class _CompostingProgressCardState extends State<CompostingProgressCard> {
  bool isStarted = false;
  String batchId = '';
  DateTime? batchStart;

  void _startBatch() async {
    final batch = await showDialog<String>(
      context: context,
      builder: (ctx) => BatchIdDialog(),
    );
    if (batch != null && batch.isNotEmpty) {
      setState(() {
        isStarted = true;
        batchId = batch;
        batchStart = DateTime.now();
      });
    }
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CompostBatchDetailDialog(
        batchId: batchId,
        batchStart: batchStart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = 0.10;
    return GestureDetector(
      onTap: isStarted ? _showDetailsDialog : null,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text('Composting Progress'),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 7,
              ),
              SizedBox(height: 10),
              if (!isStarted)
                ElevatedButton(
                  onPressed: _startBatch,
                  child: Text('Start'),
                ),
              if (isStarted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch ID: $batchId'),
                    Text('Batch Start: ${batchStart != null ? batchStart.toString() : '-'}'),
                    Text('Est Completion: null'),
                    Text('Decomposition: 10%'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
