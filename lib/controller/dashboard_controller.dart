import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/model/lugar_disponible_model.dart';
import 'package:finpay/model/usuario_model.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io'; 

class DashboardController extends GetxController {
  final RxList<Reserva> reservas = <Reserva>[].obs;
  final RxList<LugarDisponible> lugaresDisponibles = <LugarDisponible>[].obs;
  final RxList<String> vehiculosUsuario = ['ABC123', 'XYZ789'].obs;
  final String nombreUsuario = "Hernan Silgueira";

  // Reservas categorizadas
  List<Reserva> get reservasActuales => reservas
      .where((r) => r.estado == EstadoReserva.actual)
      .toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));

  List<Reserva> get reservasProximas => reservas
      .where((r) => r.estado == EstadoReserva.proxima)
      .toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));

  List<Reserva> get reservasHistorial => reservas
      .where((r) => r.estado == EstadoReserva.historial)
      .toList()
    ..sort((a, b) => b.inicio.compareTo(a.inicio)); // más recientes primero

  @override
  void onInit() {
    super.onInit();
    cargarMockReservas();
    cargarLugaresDisponibles();
  }

  // Cargar reservas desde mock
  Future<void> cargarMockReservas() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/mock_reservas.json');

    String jsonString;
    if (await file.exists()) {
      jsonString = await file.readAsString();
    } else {
      // Si no existe, lo copia desde assets
      jsonString = await rootBundle.loadString('assets/data/mock_reservas.json');
      await file.writeAsString(jsonString);
    }

    final List<dynamic> data = json.decode(jsonString);
    reservas.value = data.map((e) => Reserva.fromJson(e)).toList();
  }
  Future<void> guardarReservas() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/mock_reservas.json');
    final data = reservas.map((r) => r.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }
  Future<void> guardarLugaresDisponibles() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lugares.json');
    final data = lugaresDisponibles.map((l) => l.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  // Cargar lugares desde lugares.json
  void cargarLugaresDisponibles() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lugares.json');

    String jsonString;
    if (await file.exists()) {
      jsonString = await file.readAsString();
    } else {
      jsonString = await rootBundle.loadString('assets/data/lugares.json');
      await file.writeAsString(jsonString); // Copia inicial
    }

    final List<dynamic> data = json.decode(jsonString);
    lugaresDisponibles.value = data.map((e) => LugarDisponible.fromJson(e)).toList();
  }


  void repetirReserva(Reserva reserva) {
    final nueva = Reserva(
      lugar: reserva.lugar,
      vehiculo: reserva.vehiculo,
      inicio: DateTime.now().add(const Duration(minutes: 5)),
      duracionHoras: reserva.duracionHoras,
      costo: reserva.costo,
      estado: EstadoReserva.proxima,
    );
    reservas.add(nueva);
  }

  Future<void> cancelarReserva(Reserva reserva) async {
    final index = reservas.indexOf(reserva);
    if (index != -1) {
      reservas[index] = reserva.copyWith(estado: EstadoReserva.historial);
      await guardarReservas();
    }

    final lugar = lugaresDisponibles.firstWhereOrNull((l) => l.nombre == reserva.lugar);
    if (lugar != null) {
      lugar.ocupado = false;
      lugaresDisponibles.refresh();
      await guardarLugaresDisponibles();
    }
  }


  void ocuparLugar(String nombreLugar) {
    final index = lugaresDisponibles.indexWhere((l) => l.nombre == nombreLugar);
    if (index != -1) {
      lugaresDisponibles[index].ocupado = false;
      lugaresDisponibles.refresh();
      guardarLugaresDisponibles();
    }
  }
  final Rx<Usuario> usuario = Usuario(
    nombre: 'Hernan Silgueira',
    avatarUrl: 'assets/images/Avatar.png', // avatar placeholder
  ).obs;

  

}
