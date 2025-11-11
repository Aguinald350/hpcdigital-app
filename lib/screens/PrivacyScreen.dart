import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    const linkPolitica = 'https://politicas.apphpc.co.ao';
    const emailPrivacidade = 'hpc@hotmail.com';

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termo de Privacidade'),
        // Cores já vêm do AppBarTheme/ColorScheme, não precisamos forçar aqui.
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Hinário Povo Cantai — Política de Privacidade',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Última atualização: 26 de outubro de 2025',
            style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // Destaque inicial
          Card(
            color: cs.secondaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.policy, color: cs.primary),
              title: Text(
                'Ao usar o aplicativo HPC, você concorda com a coleta e uso de informações conforme descrito nesta política.',
                style: textTheme.bodyMedium?.copyWith(color: cs.onSecondaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _Section(
            title: 'Introdução',
            children: [
              _P(
                'Antes de usufruir dos nossos serviços, é importante que você saiba quais dados coletamos e como os utilizamos.',
              ),
              _P(
                'Ao optar por usar nossos serviços HPC, você concorda com a coleta e uso das informações. '
                    'Os dados coletados são usados primordialmente para fornecer e melhorar os serviços.',
              ),
            ],
          ),

          _Section(
            title: 'Dados Tratados e Finalidade do Tratamento',
            children: const [
              _P(
                'Podemos solicitar dados como: e-mail, nome, telefone, data de nascimento, sexo, cidade, localização, '
                    'opiniões, comentários, dados de pagamento e outros para executar e melhorar nossos serviços.',
              ),
              _Bullet('Nome completo e e-mail: identificação e liberação de acesso.'),
              _Bullet('Telefone: login por SMS e comunicações úteis.'),
              _Bullet('Pagamento e endereço: quando houver compras/entregas pelo app.'),
              _P('Você pode excluir seu perfil a qualquer momento pelo app.'),
            ],
          ),

          _Section(
            title: 'Dados Tratados por Terceiros e Finalidade',
            children: const [
              _TableLike(rows: [
                ['Finalidade', 'Serviço'],
                ['Anúncios relevantes', '—'],
                ['Armazenamento de dados', 'Firebase / Google Cloud Platform'],
                ['Login (Google)', 'Google Sign-In / Google Play Services'],
                ['Geolocalização/Mapas', 'Google Maps'],
                ['Medição e estabilidade', 'Firebase / Google Play Services'],
              ]),
              _P(
                'Coletamos também dados de registro (IP, dispositivo, SO, versão do app, data/hora, etc.). '
                    'Dados podem ser processados fora de Angola, em conformidade com esta política.',
              ),
            ],
          ),

          _Section(
            title: 'Compartilhamento de Dados',
            children: const [
              _P(
                'Podemos compartilhar dados com terceiros para facilitar/fornecer o serviço, executar funções ou analisar uso. '
                    'Esses terceiros só podem usar os dados para as finalidades contratadas.',
              ),
              _P(
                'Também poderemos compartilhar para cumprir leis/ordens, fazer cumprir termos, prevenir fraude/segurança, '
                    'ou proteger direitos/segurança de usuários ou do público.',
              ),
            ],
          ),

          const _Section(
            title: 'Links para Outros Sites',
            children: [
              _P(
                'Ao acessar sites de terceiros a partir do app, você estará sujeito às políticas de privacidade desses sites.',
              ),
            ],
          ),

          const _Section(
            title: 'Cookies',
            children: [
              _P(
                'Não utilizamos cookies explicitamente, mas bibliotecas de terceiros podem usar cookies. '
                    'Você pode recusá-los, ciente de que partes do serviço podem ser afetadas.',
              ),
            ],
          ),

          const _Section(
            title: 'Segurança',
            children: [
              _P(
                'Usamos medidas razoáveis (ex.: criptografia em trânsito). Nenhum método é 100% seguro; '
                    'notificaremos incidentes relevantes assim que possível.',
              ),
            ],
          ),

          const _Section(
            title: 'Direitos dos Titulares',
            children: [
              _P(
                'Você pode acessar, corrigir e excluir sua conta pelo app. Podemos verificar sua identidade para atender solicitações.',
              ),
            ],
          ),

          const _Section(
            title: 'Privacidade Infantil',
            children: [
              _P(
                'Serviço não destinado a menores de 12 anos. Se dados de crianças forem informados, excluiremos ao identificar o fato.',
              ),
            ],
          ),

          _Section(
            title: 'Alterações desta Política',
            children: [
              const _P('A versão vigente estará sempre disponível no link abaixo.'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openUrl(linkPolitica),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ver versão oficial'),
                ),
              ),
            ],
          ),

          _Section(
            title: 'Contato — Área de Privacidade/HPC',
            children: [
              const _P('Dúvidas e solicitações:'),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.mail_outline, color: cs.primary),
                  InkWell(
                    onTap: () => _sendEmail(emailPrivacidade),
                    child: Text(
                      emailPrivacidade,
                      style: TextStyle(
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------ widgets auxiliares ------
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: cs.primary,
          collapsedIconColor: cs.primary,
          title: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: children,
        ),
      ),
    );
  }
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: textTheme.bodyLarge?.copyWith(color: cs.primary)),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableLike extends StatelessWidget {
  final List<List<String>> rows; // primeira linha é o cabeçalho
  const _TableLike({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final header = rows.first;
    final body = rows.skip(1).toList();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border.all(color: cs.secondary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    header[0],
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    header[1],
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...body.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(child: Text(r[0], style: textTheme.bodyMedium)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r[1],
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
