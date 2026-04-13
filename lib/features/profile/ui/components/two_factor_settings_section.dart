// Ficheiro: lib/features/profile/ui/components/two_factor_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../repositories/profile_repository.dart';
import '../../viewmodels/two_factor_settings_viewmodel.dart';

/// Component for managing Two-Factor Authentication within the Profile screen.
class TwoFactorSettingsSection extends StatefulWidget {
  final ProfileRepository profileRepository;
  final bool initialTwoFactorStatus;

  const TwoFactorSettingsSection({
    super.key,
    required this.profileRepository,
    required this.initialTwoFactorStatus,
  });

  @override
  State<TwoFactorSettingsSection> createState() => _TwoFactorSettingsSectionState();
}

class _TwoFactorSettingsSectionState extends State<TwoFactorSettingsSection> {
  late final TwoFactorSettingsViewModel _viewModel;
  final _confirmationController = TextEditingController();
  bool _showRegenerateFlow = false;

  @override
  void initState() {
    super.initState();
    _viewModel = TwoFactorSettingsViewModel(profileRepository: widget.profileRepository);
    _viewModel.setInitialStatus(widget.initialTwoFactorStatus);
    
    // Automatically fetch codes if already enabled
    if (widget.initialTwoFactorStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.fetchRecoveryCodes();
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _handleRegenerate() {
    setState(() {
      _showRegenerateFlow = true;
    });
    _viewModel.enable2FA();
  }

  void _confirmSetup() async {
    if (_confirmationController.text.trim().isEmpty) return;
    final success = await _viewModel.confirm2FA(_confirmationController.text.trim());
    if (success) {
      _confirmationController.clear();
      setState(() {
        _showRegenerateFlow = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticação de 2 Fatores ativada!'), backgroundColor: Colors.green),
        );
      }
    } else if (_viewModel.errorMessage != null) {
      _showError(_viewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: _viewModel.isTwoFactorEnabled ? Colors.green : colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Autenticação de Dois Fatores (2FA)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // LOADING STATE
              if (_viewModel.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))

              // SETUP FLOW (New or Regenerate)
              else if ((!_viewModel.isTwoFactorEnabled || _showRegenerateFlow) && _viewModel.qrCodeSvg != null)
                _buildSetupFlow(colorScheme)

              // ALREADY ENABLED STATE
              else if (_viewModel.isTwoFactorEnabled)
                _buildActiveStatus(colorScheme)

              // INITIAL STATE (Not Enabled)
              else
                _buildInitialState(colorScheme),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInitialState(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicione uma camada extra de segurança à sua conta ativando o 2FA.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _viewModel.enable2FA,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Configurar 2FA'),
        ),
        if (_viewModel.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _viewModel.errorMessage!,
            style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
          ),
        ]
      ],
    );
  }

  Widget _buildActiveStatus(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text('A sua conta está protegida com Autenticação de 2 Fatores.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('O que deseja fazer?', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleRegenerate,
                icon: const Icon(Icons.refresh),
                label: const Text('Gerar Novo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _viewModel.disable2FA(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Remover'),
              ),
            ),
          ],
        ),
        
        if (_viewModel.recoveryCodes.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Códigos de Recuperação de Emergência:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(
              _viewModel.recoveryCodes.join('\n'),
              style: const TextStyle(fontFamily: 'monospace', letterSpacing: 2.0),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _viewModel.regenerateRecoveryCodes,
            icon: const Icon(Icons.refresh),
            label: const Text('Gerar Novos Códigos'),
          ),
        ],
      ],
    );
  }

  Widget _buildSetupFlow(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Leia o código QR com a sua aplicação de autenticação:'),
        const SizedBox(height: 16),
        Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: SvgPicture.string(
              _viewModel.qrCodeSvg!,
              height: 180,
              width: 180,
              placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_viewModel.setupKey != null) ...[
          const Text('Ou insira esta chave manualmente:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _viewModel.setupKey!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copiar Chave',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _viewModel.setupKey!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chave copiada para a área de transferência!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text('2. Confirme o código de 6 dígitos:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _confirmationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '000 000',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _confirmSetup,
              child: const Text('Confirmar'),
            )
          ],
        ),
        if (_showRegenerateFlow) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showRegenerateFlow = false),
              child: const Text('Cancelar e manter o atual'),
            ),
          ),
        ],
      ],
    );
  }
}