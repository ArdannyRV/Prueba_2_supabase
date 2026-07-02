class TelefonoValidator {
  static const int longitudExacta = 10; // AJUSTAR si el estándar local es otro

  static bool validar(String valor) {
    if (!RegExp(r'^[0-9]+$').hasMatch(valor)) return false;
    return valor.length == longitudExacta;
  }
}
