import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../model/reservas_model.dart';
import '../model/usuario_model.dart';
import '../model/pago_model.dart';
import '../model/lugar_disponible_model.dart';
import 'package:finpay/model/vehiculo.dart';

class DashboardController extends GetxController {
  // Listas observables principales
  RxList<Reserva> reservas = <Reserva>[].obs;
  RxList<LugarDisponible> lugares = <LugarDisponible>[].obs;
  Rx<Usuario> usuario = Usuario(
  nombre: "Hernan Silgueira",
  avatar: "",
  vehiculos: ["ABC123", "DEF456"], // <-- PON AQUÍ LAS PLACAS QUE QUIERES QUE VEA EL USUARIO
).obs;
  RxList<Pago> pagos = <Pago>[].obs;
  RxList<Vehiculo> vehiculos = <Vehiculo>[].obs; // <-- NUEVO: lista de todos los vehículos

  // Listas auxiliares

  List<LugarDisponible> lugaresDisponibles = [];
  List<String> vehiculosUsuario = [];

  // Getters útiles
  List<Reserva> get reservasNoPagadas =>
      reservas.where((r) => !r.pagado).toList();

  List<Pago> get listaPagosEsteMes {
    final ahora = DateTime.now();
    return pagos.where((p) =>
      p.fecha.year == ahora.year && p.fecha.month == ahora.month
    ).toList();
  }

  List<Reserva> get reservasPendientes => reservas.where((r) => !r.pagado).toList();
  
  List<Reserva> get reservasActuales {
    final ahora = DateTime.now();
    return reservas.where((r) =>
      r.estado == EstadoReserva.activa &&
      r.fechaHoraInicio.isBefore(ahora) &&
      r.fechaHoraFin.isAfter(ahora)
    ).toList();
  }

  List<Reserva> get reservasHistorial {
    final ahora = DateTime.now();
    return reservas.where((r) =>
      r.estado == EstadoReserva.cancelada ||
      r.fechaHoraFin.isBefore(ahora)
    ).toList();
  }

  List<Reserva> get reservasProximas {
    final ahora = DateTime.now();
    return reservas.where((r) =>
      r.estado == EstadoReserva.activa &&
      r.fechaHoraInicio.isAfter(ahora)
    ).toList();
  }

  // PATHS
  final String reservasFile = 'assets/data/reservas.json';
  final String lugaresFile = 'assets/data/lugares.json';
  final String pagosFile = 'assets/data/pagos.json';
  final String vehiculosFile = 'assets/data/vehiculos.json'; // <-- nuevo

  /// ==== PUNTO 3: Getter para obtener detalles de los vehículos del usuario ====
  List<Vehiculo> get vehiculosUsuarioDetalles {
  final resultado = vehiculos.where((v) => usuario.value.vehiculos.contains(v.placa)).toList();
  print('Vehículos usuario detalles: ${resultado.map((v) => v.placa).toList()}');
  return resultado;
}

  @override
  void onInit() {
    super.onInit();
    cargarVehiculos();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      await cargarLugares();
    } catch (e, stack) {
      print('Error al cargar lugares: $e');
      print(stack);
    }

    try {
      await cargarVehiculos(); // <-- cargar todos los vehículos
    } catch (e, stack) {
      print('Error al cargar vehículos: $e');
      print(stack);
    }

    try {
      await cargarReservas();
    } catch (e, stack) {
      print('Error al cargar reservas: $e');
      print(stack);
    }

    try {
      await cargarPagos();
    } catch (e, stack) {
      print('Error al cargar pagos: $e');
      print(stack);
    }

    lugaresDisponibles = lugares.where((l) => !l.ocupado).toList();
    vehiculosUsuario = usuario.value.vehiculos ?? [];
    update();
  }

  // ==== Métodos de carga y guardado de archivos locales ====
  Future<File> _getLocalFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<void> cargarLugares() async {
    final file = await _getLocalFile('lugares.json');
    if (await file.exists()) {
      final contenido = await file.readAsString();
      final data = jsonDecode(contenido) as List;
      lugares.value = data.map((e) => LugarDisponible.fromJson(e)).toList();
    } else {
      final contenido = await rootBundle.loadString(lugaresFile);
      final data = jsonDecode(contenido) as List;
      lugares.value = data.map((e) => LugarDisponible.fromJson(e)).toList();
    }
  }

  Future<void> guardarLugares() async {
    final file = await _getLocalFile('lugares.json');
    await file.writeAsString(jsonEncode(lugares.map((e) => e.toJson()).toList()));
  }

  Future<void> cargarReservas() async {
    final file = await _getLocalFile('reservas.json');
    if (await file.exists()) {
      final contenido = await file.readAsString();
      final data = jsonDecode(contenido) as List;
      reservas.value = data.map((e) => Reserva.fromJson(e, lugaresDisponibles)).toList();
    } else {
      final contenido = await rootBundle.loadString(reservasFile);
      final data = jsonDecode(contenido) as List;
      reservas.value = data.map((e) => Reserva.fromJson(e, lugaresDisponibles)).toList();
    }
  }

  Future<void> guardarReservas() async {
    final file = await _getLocalFile('reservas.json');
    await file.writeAsString(jsonEncode(reservas.map((e) => e.toJson()).toList()));
  }

  Future<void> cargarPagos() async {
    final file = await _getLocalFile('pagos.json');
    if (await file.exists()) {
      final contenido = await file.readAsString();
      final data = jsonDecode(contenido) as List;
      pagos.value = data.map((e) => Pago.fromJson(e)).toList();
    } else {
      pagos.clear();
    }
  }

  Future<void> guardarPagos() async {
    final file = await _getLocalFile('pagos.json');
    await file.writeAsString(jsonEncode(pagos.map((e) => e.toJson()).toList()));
  }

  /// ==== NUEVO: Métodos para cargar y guardar vehículos ====
  Future<void> cargarVehiculos() async {
    final file = await _getLocalFile('vehiculos.json');
    if (await file.exists()) {
      final contenido = await file.readAsString();
      final data = jsonDecode(contenido) as List;
      vehiculos.value = data.map((e) => Vehiculo.fromJson(e)).toList();
    } else {
      final contenido = await rootBundle.loadString(vehiculosFile);
      final data = jsonDecode(contenido) as List;
      vehiculos.value = data.map((e) => Vehiculo.fromJson(e)).toList();
    }

    print('Vehículos cargados: ${vehiculos.map((v) => v.placa).toList()}');
  }

  Future<void> guardarVehiculos() async {
    final file = await _getLocalFile('vehiculos.json');
    await file.writeAsString(jsonEncode(vehiculos.map((e) => e.toJson()).toList()));
  }

  // ==== CRUD y lógica de reservas ====
  Future<void> crearReserva({
    required LugarDisponible lugarSeleccionado,
    required double duracionHoras,
    required String vehiculo, // <-- aquí recibes la placa seleccionada
  }) async {
    final DateTime inicio = DateTime.now();
    final DateTime fin = inicio.add(Duration(hours: duracionHoras.toInt()));
    final double precio = lugarSeleccionado.precioPorHora * duracionHoras;

    final nuevaReserva = Reserva(
      id: 'resv_${DateTime.now().millisecondsSinceEpoch}',
      lugar: lugarSeleccionado,
      vehiculo: vehiculo, // <-- guardas la placa
      fechaHoraInicio: inicio,
      fechaHoraFin: fin,
      precio: precio,
      estado: EstadoReserva.activa,
    );

    reservas.add(nuevaReserva);
    await guardarReservas();
    update();
  }

  void agregarReserva(Reserva nuevaReserva) {
    reservas.add(nuevaReserva);
    update();
  }

  Future<void> pagarReservaActual(Reserva reserva, String metodoPago) async {
    final reservaPagada = reserva.copyWith(
      estado: EstadoReserva.completada,
      metodoPago: metodoPago,
    );
    final index = reservas.indexWhere((r) => r.id == reserva.id);
    if (index != -1) {
      reservas[index] = reservaPagada;
      await guardarReservas();
      update();
    }
  }
  Future<void> registrarPago(Reserva reserva, String metodoPago) async {
    final nuevoPago = Pago(
      id: pagos.length + 1,
      reservaId: reserva.id,
      metodo: metodoPago,
      fecha: DateTime.now(),
      monto: reserva.precio,
    );
    pagos.add(nuevoPago);
    await guardarPagos();
    final index = reservas.indexWhere((r) => r.id == reserva.id);
    if (index != -1) {
      reservas[index] = reservas[index].copyWith(
        metodoPago: metodoPago,
        estado: EstadoReserva.completada,
      );
      await guardarReservas();
    }
  }

  Future<void> cancelarReserva(int idReserva) async {
    final index = reservas.indexWhere((r) => r.id == idReserva);
    if (index != -1) {
      final reserva = reservas[index];
      final lugar = lugares.firstWhereOrNull((l) => l.nombre == reserva.lugar);
      if (lugar != null) {
        lugar.ocupado = false;
        await guardarLugares();
      }
      reservas.removeAt(index);
      await guardarReservas();
    }
  }

  void liberarLugar(String idReserva) {
    final index = reservas.indexWhere((r) => r.id == idReserva);
    if (index != -1) {
      final reserva = reservas[index];
      final reservaActualizada = reserva.copyWith(estado: EstadoReserva.completada);
      reservas[index] = reservaActualizada;
      update();
    }
  }

  /// ==== PUNTO 5: Obtener detalles del vehículo de una reserva ====
  Vehiculo? obtenerVehiculoDeReserva(Reserva reserva) {
    return vehiculos.firstWhereOrNull((v) => v.placa == reserva.vehiculo);
  }
}