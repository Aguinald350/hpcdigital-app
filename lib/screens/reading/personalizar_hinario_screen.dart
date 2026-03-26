import 'package:flutter/material.dart';
import '../../reading/reading_preferences_controller.dart';

class PersonalizarHinarioScreen extends StatefulWidget {
  const PersonalizarHinarioScreen({super.key});

  @override
  State<PersonalizarHinarioScreen> createState() =>
      _PersonalizarHinarioScreenState();
}

class _PersonalizarHinarioScreenState
    extends State<PersonalizarHinarioScreen> {
  @override
  void initState() {
    super.initState();
    readingPreferencesController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: readingPreferencesController,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Personalizar Leitura"),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// TAMANHO DA LETRA
              const Text("Tamanho da letra",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      readingPreferencesController
                          .setFontSize(
                          readingPreferencesController.fontSize - 1);
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value:
                      readingPreferencesController.fontSize,
                      min: 14,
                      max: 30,
                      divisions: 16,
                      label: readingPreferencesController.fontSize
                          .toStringAsFixed(0),
                      onChanged: (v) {
                        readingPreferencesController
                            .setFontSize(v);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      readingPreferencesController
                          .setFontSize(
                          readingPreferencesController.fontSize + 1);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ESPAÇAMENTO
              const Text("Espaçamento entre linhas",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value:
                readingPreferencesController.lineSpacing,
                min: 1.0,
                max: 2.5,
                divisions: 15,
                onChanged: (v) {
                  readingPreferencesController
                      .setLineSpacing(v);
                },
              ),

              const SizedBox(height: 20),

              /// ALINHAMENTO
              const Text("Alinhamento",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<ReadingAlignment>(
                value: readingPreferencesController.alignment,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: ReadingAlignment.left,
                    child: Text("Esquerda"),
                  ),
                  DropdownMenuItem(
                    value: ReadingAlignment.center,
                    child: Text("Centro"),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    readingPreferencesController
                        .setAlignment(v);
                  }
                },
              ),

              const SizedBox(height: 20),

              /// TEMA
              const Text("Tema de leitura",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<ReadingThemeMode>(
                value: readingPreferencesController.themeMode,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: ReadingThemeMode.light,
                    child: Text("Claro"),
                  ),
                  DropdownMenuItem(
                    value: ReadingThemeMode.dark,
                    child: Text("Escuro"),
                  ),
                  DropdownMenuItem(
                    value: ReadingThemeMode.sepia,
                    child: Text("Sépia"),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    readingPreferencesController
                        .setThemeMode(v);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
