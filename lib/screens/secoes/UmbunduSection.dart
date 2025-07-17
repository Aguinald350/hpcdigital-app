import 'package:flutter/material.dart';

class UmbunduSection extends StatelessWidget {
  const UmbunduSection({super.key});

  @override
  Widget build(BuildContext context) {
    final assuntos = [
      'Esivayo Lefendelo (1–12)',
      'Espiritu Sandu (13–17)',
      'Ucito wa Yesu Kristu (18–23)',
      'Okufa kua Ñala Yesu Kristu (24–28)',
      'Epinduko lia Yesu Kristu (29–33)',
      'Ekongelo lia Yesu Kristu (34–36)',
      'Epata Lietavo lia Kristu (37–40)',
      'Omesa ya Ñala Yesu Kristu (41–46)',
      'Oku Laleka (47–54)',
      'Oku Likutíllia (55–65)',
      'Oku Litumbika (66–72)',
      'Ekololo Lelembekeleo (73–87)',
      'Uvangi Lupange (88–94)',
      'Olopandu (95–102)',
      'Ovisungo Vioñolosi (103–105)',
      'Embímbiliya (106–109)',
      'Ovisungo Viomala (110–113)',
      'Okufa Kukua Kristu (114–119)',
      'Oku Yalula (120–123)',
      'Oku Tumbangiya (124–129)',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: const [
                Icon(Icons.category, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Assuntos dos Hinos - Umbundu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...assuntos.map((assunto) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.music_note, color: Colors.deepOrange),
                title: Text(assunto),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
