class CedulaValidator {
  static bool validar(String? cedula) {
    if (cedula == null || cedula.isEmpty) return false;
    
    // 1. Debe tener exactamente 10 dígitos y ser solo números
    if (cedula.length != 10) return false;
    if (!RegExp(r'^[0-9]+$').hasMatch(cedula)) return false;

    // 2. Los dos primeros dígitos corresponden a la provincia (01 a 24)
    final int provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) {
      // Nota: 30 es para ecuatorianos en el exterior, puedes agregarlo si deseas:
      // if (provincia < 1 || (provincia > 24 && provincia != 30)) return false;
      return false;
    }

    // 3. El tercer dígito es menor a 6 para personas naturales
    final int tercerDigito = int.parse(cedula[2]);
    if (tercerDigito >= 6) return false;

    // 4. Algoritmo Módulo 10
    final List<int> coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]) * coeficientes[i];
      // Si la multiplicación es mayor a 9, se le resta 9
      if (valor > 9) {
        valor -= 9;
      }
      suma += valor;
    }

    // 5. Se obtiene la decena superior
    int decenaSuperior = ((suma + 9) ~/ 10) * 10;
    
    // 6. El resultado de la resta debe ser igual al décimo dígito
    int resultado = decenaSuperior - suma;
    if (resultado == 10) {
      resultado = 0;
    }

    final int digitoVerificador = int.parse(cedula[9]);
    return resultado == digitoVerificador;
  }
}