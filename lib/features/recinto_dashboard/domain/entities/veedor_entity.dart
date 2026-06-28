class VeedorEntity {
  final String id;
  final String? cedula;
  final String? nombres;
  final String? apellidos;
  final String? telefono;
  final String? correo;
  final String? mesaAsignada; // "Mesa N°X" o null

  const VeedorEntity({
    required this.id,
    this.cedula,
    this.nombres,
    this.apellidos,
    this.telefono,
    this.correo,
    this.mesaAsignada,
  });

  String get nombreCompleto => '${nombres ?? ''} ${apellidos ?? ''}'.trim();
}
