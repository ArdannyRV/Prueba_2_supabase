class NombreValidator {
  static final RegExp _soloLetras = 
      RegExp(r'^[A-Za-zÁÉÍÓÚÑáéíóúñÜü\s]+$');

  static bool validar(String valor) {
    if (valor.trim().isEmpty) return false;
    return _soloLetras.hasMatch(valor);
  }
}
