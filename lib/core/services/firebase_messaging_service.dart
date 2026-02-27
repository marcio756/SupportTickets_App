import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // Para o kIsWeb
import 'package:flutter/material.dart';
import '../network/api_client.dart'; // Ajusta este import para o caminho correto do teu ApiClient

/// Função de topo (obrigatoriamente fora de qualquer classe) 
/// O sistema operativo acorda esta função quando a app está fechada/minimizada.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Notificação recebida em Background: ${message.messageId}");
}

class FirebaseMessagingService {
  // Singleton pattern (Garante que só existe uma instância deste serviço a correr)
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Inicializa o escutador de notificações e pede permissão ao utilizador.
  /// Passamos o BuildContext para podermos desenhar um Snackbar quando a App está aberta.
  Future<void> init(BuildContext context, ApiClient apiClient) async {
    if (_isInitialized) return;

    // 1. Configurar o recetor de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Pedir permissão ao utilizador (Mostra um pop-up no Android 13+ e iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Permissão de Notificações concedida na App.');

      // 3. Obter o Token do telemóvel e enviar ao Laravel
      await registerTokenWithBackend(apiClient);

      // 4. Se a Google renovar o token do telemóvel por segurança, atualizamos no backend
      _messaging.onTokenRefresh.listen((newToken) {
        _sendTokenToLaravel(newToken, apiClient);
      });

      // 5. Escutar notificações em Foreground (quando tens a App aberta a uso)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Mensagem recebida em Foreground: ${message.notification?.title}');
        
        if (message.notification != null) {
          // Mostrar um pop-up (Snackbar) no topo/baixo do ecrã
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.notification?.title}\n${message.notification?.body}'),
              backgroundColor: Colors.blueGrey.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });

      _isInitialized = true;
    } else {
      log('Permissão de Notificações negada pelo utilizador.');
    }
  }

  /// Pede o Token de identificação à Google e despacha-o
  Future<void> registerTokenWithBackend(ApiClient apiClient) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _sendTokenToLaravel(token, apiClient);
      }
    } catch (e) {
      log('Erro ao obter FCM Token: $e');
    }
  }

  /// Faz o pedido POST à nossa rota da API com o Bearer Token do utilizador logado
  Future<void> _sendTokenToLaravel(String token, ApiClient apiClient) async {
    try {
      // Descobrir que tipo de telemóvel está a ser usado
      String deviceType = 'unknown';
      if (kIsWeb) {
        deviceType = 'web';
      } else if (Platform.isAndroid) {
        deviceType = 'android';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
      }

      // Faz a chamada HTTP ao Laravel
      // NOTA: Ajusta `apiClient.post` consoante o nome do método que usas no teu ApiClient (ex: dio.post, http.post, etc)
      await apiClient.post('/api/fcm-token', data: {
        'token': token,
        'device_type': deviceType,
      });
      
      log('FCM Token da App registado no Backend com sucesso!');
    } catch (e) {
      log('Falha ao registar o token da app no Backend: $e');
    }
  }
}