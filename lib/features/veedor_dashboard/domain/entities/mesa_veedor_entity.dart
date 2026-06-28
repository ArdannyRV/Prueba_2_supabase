class MesaVeedorEntity {
  final String id;
  final int numeroMesa;
  final String recintoNombre;
  final bool tieneActaAlcaldia;
  final bool tieneActaPrefectura;

  const MesaVeedorEntity({
    required this.id,
    required this.numeroMesa,
    required this.recintoNombre,
    this.tieneActaAlcaldia = false,
    this.tieneActaPrefectura = false,
  });

  bool get tieneAmbasActas => tieneActaAlcaldia && tieneActaPrefectura;
}
