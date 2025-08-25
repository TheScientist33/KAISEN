import 'package:flutter/material.dart';

class CardioRespiPage extends StatefulWidget {
  const CardioRespiPage({super.key});

  @override
  State<CardioRespiPage> createState() => _CardioRespiPageState();
}

class _CardioRespiPageState extends State<CardioRespiPage> {
  bool bleConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardio‑respiratoire"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Ex: 5s expiration • 3s pause • 5 cycles",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Guide visuel respiration
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text("(Guide visuel respiration)",
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bloc Spiromètre BLE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Spiromètre BLE",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text("État: ${bleConnected ? "Connecté" : "Non connecté"}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            bleConnected = !bleConnected;
                          });
                        },
                        child: Text(bleConnected ? "Déconnecter" : "Connecter"),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Tester mesure"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Boutons de contrôle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade100,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.timer),
                    label: const Text("Lancer"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Pause"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Terminer"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
