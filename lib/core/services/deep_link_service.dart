import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void init({required void Function() onEmailVerified}) async {
    // 1. Manejar el link inicial si la app estaba cerrada (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, onEmailVerified);
      }
    } catch (e) {
      // Ignorar errores de getInitialLink
    }

    // 2. Escuchar links mientras la app está abierta en background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri, onEmailVerified);
      },
      onError: (err) {
        // Ignorar errores del stream
      },
    );
  }

  void _handleDeepLink(Uri uri, void Function() onEmailVerified) async {
    // Validar el scheme y host esperados para la confirmación de email
    if (uri.scheme == 'loginpro' && uri.host == 'verified') {
      try {
        // Cerrar sesión local persistida para forzar nuevo login
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        // En caso de que signOut falle, igual notificamos el evento
      } finally {
        onEmailVerified();
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
