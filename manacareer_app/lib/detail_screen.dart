import 'package:flutter/material.dart';
import 'opportunity.dart';

class DetailScreen extends StatelessWidget {
  final Opportunity opp;
  const DetailScreen({super.key, required this.opp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213B),
        foregroundColor: Colors.white,
        title: Text(opp.org),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opp.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(opp.org, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(opp.location),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(opp.money, style: const TextStyle(color: Colors.green)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.timer, size: 16, color: opp.urgent ? Colors.red : Colors.grey),
              const SizedBox(width: 4),
              Text(opp.deadline, style: TextStyle(color: opp.urgent ? Colors.red : Colors.black)),
            ]),
            const Divider(height: 32),
            const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(opp.about, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 20),
            const Text('Eligibility', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...opp.eligibility.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(fontSize: 15)),
                Expanded(child: Text(e, style: const TextStyle(height: 1.5))),
              ]),
            )),
            const SizedBox(height: 20),
            const Text('How to Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(opp.applyInfo, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2A33B),
                  foregroundColor: const Color(0xFF16213B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}