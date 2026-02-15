class ConfiguracionJuego {
  bool modoContraReloj;
  int minutosReloj;
  bool modoCaos;
  // bool modoSilencio; <-- ELIMINADO (Se mueve a roles)
  bool modoRuleta;
  bool modoVotacionAnonima;

  // Ajustes de Impostor
  bool impostorTienePista;
  bool impostoresSeConocen;
  bool muerteSincronizada;

  // NUEVOS ROLES
  bool rolSilencioso; // Antes modoSilencio
  bool rolDetective;
  bool rolComplice;

  Map<String, bool> categoriasActivas;

  ConfiguracionJuego({
    this.modoContraReloj = false,
    this.minutosReloj = 5,
    this.modoCaos = false,
    this.modoRuleta = false,
    this.modoVotacionAnonima = false,
    this.impostorTienePista = false,
    this.impostoresSeConocen = false,
    this.muerteSincronizada = false,

    // Default roles false
    this.rolSilencioso = false,
    this.rolDetective = false,
    this.rolComplice = false,

    required this.categoriasActivas,
  });
}

class JugadorEnPartida {
  final String nombre;
  final bool esImpostor;
  final bool esComplice; // Nuevo
  bool esDetective;      // Nuevo (se asigna en el debate)
  bool estaVivo;
  bool estaSilenciado;

  JugadorEnPartida({
    required this.nombre,
    required this.esImpostor,
    this.esComplice = false,
    this.esDetective = false,
    this.estaVivo = true,
    this.estaSilenciado = false
  });
}