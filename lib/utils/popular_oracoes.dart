import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> popularOracoes() async {
  final oracoes = <Map<String, String>>[
    // manhã (5)
    {"titulo":"Oração da Manhã 1","texto":"Senhor, guia meus passos neste novo dia. Que eu leve luz, amor e paz por onde for.","tema":"manhã"},
    {"titulo":"Oração da Manhã 2","texto":"Agradeço por acordar com vida. Que cada atitude minha reflita a Tua vontade.","tema":"manhã"},
    {"titulo":"Oração da Manhã 3","texto":"Pai amado, abençoa o meu trabalho e as minhas decisões de hoje.","tema":"manhã"},
    {"titulo":"Oração da Manhã 4","texto":"Que o amanhecer traga esperança, e o Teu Espírito renove minhas forças.","tema":"manhã"},
    {"titulo":"Oração da Manhã 5","texto":"Senhor, entrego este dia em Tuas mãos — que ele seja para a Tua glória.","tema":"manhã"},

    // noite (5)
    {"titulo":"Oração da Noite 1","texto":"Obrigado, Senhor, por mais um dia vivido. Que o Teu descanso renove minha alma.","tema":"noite"},
    {"titulo":"Oração da Noite 2","texto":"Entrego em Tuas mãos todas as minhas preocupações. Em Ti, encontro paz.","tema":"noite"},
    {"titulo":"Oração da Noite 3","texto":"Senhor, perdoa-me pelos erros de hoje e guarda-me sob Teu cuidado.","tema":"noite"},
    {"titulo":"Oração da Noite 4","texto":"Que o Teu amor seja meu abrigo enquanto durmo.","tema":"noite"},
    {"titulo":"Oração da Noite 5","texto":"A Ti confio meu sono, Senhor. Que Tua presença habite em meu coração.","tema":"noite"},

    // gratidão (5)
    {"titulo":"Oração de Gratidão 1","texto":"Obrigado, Senhor, por tudo que tens feito — até o que não entendo é bênção.","tema":"gratidão"},
    {"titulo":"Oração de Gratidão 2","texto":"Gratidão por mais um dia, por cada respiro e pela Tua fidelidade.","tema":"gratidão"},
    {"titulo":"Oração de Gratidão 3","texto":"Sou grato pelas lutas que me fortalecem e pelas vitórias que me ensinam humildade.","tema":"gratidão"},
    {"titulo":"Oração de Gratidão 4","texto":"Obrigado, Pai, por nunca desistir de mim, mesmo quando eu falho.","tema":"gratidão"},
    {"titulo":"Oração de Gratidão 5","texto":"Gratidão é a oração que nunca cansa de ser dita: obrigado, Senhor!","tema":"gratidão"},

    // perdão (5)
    {"titulo":"Oração de Perdão 1","texto":"Senhor, ensina-me a perdoar como Tu me perdoas, sem guardar mágoas.","tema":"perdão"},
    {"titulo":"Oração de Perdão 2","texto":"Liberta-me do peso do ressentimento e renova meu coração em amor.","tema":"perdão"},
    {"titulo":"Oração de Perdão 3","texto":"Pai, peço perdão pelos meus pecados e forças para recomeçar.","tema":"perdão"},
    {"titulo":"Oração de Perdão 4","texto":"Ajuda-me a entender que perdoar é libertar a alma da prisão da dor.","tema":"perdão"},
    {"titulo":"Oração de Perdão 5","texto":"Senhor, que o Teu perdão me lave e me torne instrumento de reconciliação.","tema":"perdão"},

    // sabedoria (5)
    {"titulo":"Oração de Sabedoria 1","texto":"Espírito Santo, concede-me discernimento em cada escolha de hoje.","tema":"sabedoria"},
    {"titulo":"Oração de Sabedoria 2","texto":"Senhor, que eu ouça mais e fale menos, buscando entender antes de agir.","tema":"sabedoria"},
    {"titulo":"Oração de Sabedoria 3","texto":"Dá-me sabedoria para agir com amor e paciência diante dos desafios.","tema":"sabedoria"},
    {"titulo":"Oração de Sabedoria 4","texto":"Que as minhas palavras e atitudes reflitam a Tua sabedoria divina.","tema":"sabedoria"},
    {"titulo":"Oração de Sabedoria 5","texto":"Pai, ensina-me a ver com Teus olhos e a decidir com Teu coração.","tema":"sabedoria"},

    // proteção (5)
    {"titulo":"Oração de Proteção 1","texto":"Senhor, cobre-me com Teu manto e livra-me de todo mal visível e invisível.","tema":"proteção"},
    {"titulo":"Oração de Proteção 2","texto":"Guarda meu lar, minha família e os caminhos por onde eu andar.","tema":"proteção"},
    {"titulo":"Oração de Proteção 3","texto":"Que Teus anjos acampem ao meu redor e me sustentem em segurança.","tema":"proteção"},
    {"titulo":"Oração de Proteção 4","texto":"Em Ti confio, Senhor — és meu escudo, minha fortaleza e refúgio.","tema":"proteção"},
    {"titulo":"Oração de Proteção 5","texto":"Nenhum mal prevalecerá, pois o Senhor é quem me protege e guia.","tema":"proteção"},

    // esperança (5)
    {"titulo":"Oração de Esperança 1","texto":"Mesmo nas tempestades, Senhor, mantém viva em mim a chama da esperança.","tema":"esperança"},
    {"titulo":"Oração de Esperança 2","texto":"Quando eu cansar, lembra-me que o amanhã é Tua promessa de recomeço.","tema":"esperança"},
    {"titulo":"Oração de Esperança 3","texto":"A fé me sustenta e a esperança me faz seguir confiando em Ti.","tema":"esperança"},
    {"titulo":"Oração de Esperança 4","texto":"Senhor, renova em mim a alegria de esperar com paciência o Teu tempo.","tema":"esperança"},
    {"titulo":"Oração de Esperança 5","texto":"O Teu amor é a certeza de que o impossível pode acontecer.","tema":"esperança"},

    // cura (5)
    {"titulo":"Oração de Cura 1","texto":"Senhor, toca com Teu poder as feridas do corpo e da alma.","tema":"cura"},
    {"titulo":"Oração de Cura 2","texto":"Em Ti confio, médico das almas, que cura com amor e compaixão.","tema":"cura"},
    {"titulo":"Oração de Cura 3","texto":"Pai, restaura o que está ferido e dá-me força para me reerguer.","tema":"cura"},
    {"titulo":"Oração de Cura 4","texto":"Cura-me, Senhor, de toda dor, medo e incredulidade.","tema":"cura"},
    {"titulo":"Oração de Cura 5","texto":"Que a Tua presença traga saúde, paz e vida em abundância.","tema":"cura"}
  ];

  final col = FirebaseFirestore.instance.collection('oracoes');

  final batch = FirebaseFirestore.instance.batch();
  for (final o in oracoes) {
    final docRef = col.doc(); // id automático
    batch.set(docRef, {
      'titulo'     : o['titulo'],
      'texto'      : o['texto'],
      'tema'       : o['tema'],
      'dataCriacao': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
