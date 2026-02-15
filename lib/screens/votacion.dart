import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class PantallaVotacionTurnos extends StatefulWidget {
  final List<JugadorEnPartida> listaJugadores;
  final Function(String?) onTerminarVotacion;

  const PantallaVotacionTurnos({super.key, required this.listaJugadores, required this.onTerminarVotacion});

  @override
  State<PantallaVotacionTurnos> createState() => _PantallaVotacionTurnosState();
}

class _PantallaVotacionTurnosState extends State<PantallaVotacionTurnos> {
  late List<String> votantesVivos;
  int turnoIndex = 0;
  bool esperandoJugador = true;
  Map<String, int> conteoVotos = {};

  @override
  void initState() {
    super.initState();
    votantesVivos = widget.listaJugadores.where((j) => j.estaVivo).map((j) => j.nombre).toList();
    for (var j in widget.listaJugadores) {
      if (j.estaVivo) conteoVotos[j.nombre] = 0;
    }
  }

  void registrarVoto(String? votado) {
    if (votado != null) {
      conteoVotos[votado] = (conteoVotos[votado] ?? 0) + 1;
    }

    if (turnoIndex < votantesVivos.length - 1) {
      setState(() {
        turnoIndex++;
        esperandoJugador = true;
      });
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PantallaConteoAnimado(
        listaJugadores: widget.listaJugadores,
        conteoVotos: conteoVotos,
        onTerminarAnimacion: widget.onTerminarVotacion,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (esperandoJugador) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: duoBorder, width: 4)
                  ),
                  child: const Icon(Icons.how_to_vote, size: 80, color: duoTextSub)
              ),
              const SizedBox(height: 40),
              Text("TURNO DE VOTAR:", style: duoFont(size: 20, color: duoTextSub)),
              const SizedBox(height: 10),
              // CORREGIDO: Usa el color del tema elegido
              Text(votantesVivos[turnoIndex], style: duoFont(size: 45, color: AppTheme.primary)),
              const SizedBox(height: 60),
              // CORREGIDO: Botón con color del tema
              SizedBox(
                  width: 200,
                  child: DuoButton(
                      text: "VOTAR",
                      color: AppTheme.primary,
                      onPressed: () => setState(() => esperandoJugador = false)
                  )
              )
            ],
          ),
        ),
      );
    }

    String votanteActual = votantesVivos[turnoIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // CORREGIDO: Reemplacé duoOrange por duoYellow (que sí existe) o color fijo
                  Text("VOTA EN SECRETO", style: duoFont(size: 24, color: const Color(0xFFFF9600))),
                  Text(votanteActual, style: TextStyle(color: duoTextSub, fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.listaJugadores.length,
                itemBuilder: (context, index) {
                  final candidato = widget.listaJugadores[index];
                  if (!candidato.estaVivo) return const SizedBox();

                  if (candidato.nombre == votanteActual) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DuoButton(
                      text: candidato.nombre,
                      color: duoSurface,
                      shadowColor: duoBorder,
                      onPressed: () => registrarVoto(candidato.nombre),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DuoButton(
                text: "SALTAR",
                color: duoSurface,
                shadowColor: duoBorder,
                onPressed: () => registrarVoto(null),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PantallaConteoAnimado extends StatefulWidget {
  final List<JugadorEnPartida> listaJugadores;
  final Map<String, int> conteoVotos;
  final Function(String?) onTerminarAnimacion;

  const PantallaConteoAnimado({super.key, required this.listaJugadores, required this.conteoVotos, required this.onTerminarAnimacion});

  @override
  State<PantallaConteoAnimado> createState() => _PantallaConteoAnimadoState();
}

class _PantallaConteoAnimadoState extends State<PantallaConteoAnimado> {
  Map<String, int> votosVisibles = {};

  @override
  void initState() {
    super.initState();
    for (var j in widget.listaJugadores) {
      if (j.estaVivo) votosVisibles[j.nombre] = 0;
    }
    _iniciarSecuenciaVotos();
  }

  void _iniciarSecuenciaVotos() async {
    int maxVotos = 0;
    widget.conteoVotos.forEach((key, value) {
      if (value > maxVotos) maxVotos = value;
    });

    await Future.delayed(const Duration(seconds: 1));

    for (int i = 1; i <= maxVotos; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        widget.conteoVotos.forEach((nombre, total) {
          if (total >= i) {
            votosVisibles[nombre] = i;
          }
        });
      });
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _calcularResultado();
  }

  void _calcularResultado() {
    String? eliminado;
    int maxVotos = -1;
    bool empate = false;

    widget.conteoVotos.forEach((nombre, votos) {
      if (votos > maxVotos) {
        maxVotos = votos;
        eliminado = nombre;
        empate = false;
      } else if (votos == maxVotos) {
        empate = true;
      }
    });

    if (empate) eliminado = null;

    Navigator.pop(context);
    widget.onTerminarAnimacion(eliminado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              // CORREGIDO: Usa el color del tema
              child: Text("RESULTADOS", style: duoFont(size: 30, color: AppTheme.primary)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.listaJugadores.length,
                itemBuilder: (context, index) {
                  final jugador = widget.listaJugadores[index];
                  if (!jugador.estaVivo) return const SizedBox();

                  int votos = votosVisibles[jugador.nombre] ?? 0;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: duoSurface,
                        border: Border.all(color: duoBorder, width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(jugador.nombre, style: duoFont(size: 16)),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            children: List.generate(votos, (i) => const Icon(Icons.person, color: duoRed, size: 24)),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text("Contando votos...", style: TextStyle(color: duoTextSub, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}