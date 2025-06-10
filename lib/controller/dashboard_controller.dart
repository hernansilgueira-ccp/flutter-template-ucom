import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../model/reservas_model.dart';
import '../model/usuario_model.dart';
import '../model/pago_model.dart';
import 'package:finpay/model/lugar_disponible_model.dart';

class DashboardController extends GetxController {
  RxList<Reserva> reservas = <Reserva>[].obs;
  RxList<LugarDisponible> lugares = <LugarDisponible>[].obs;
  Rx<Usuario> usuario = Usuario(nombre: "Invitado", avatar: "").obs;
  RxList<Pago> pagos = <Pago>[].obs;

  List<Reserva> get reservasNoPagadas => 
      reservas.where((r) => !r.pagado).toList();

  List<LugarDisponible> lugaresDisponibles = [];
  List<String> vehiculosUsuario = [];

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
  final String reservasFile = 'assets/data/reservas.json';
  final String lugaresFile = 'assets/data/lugares.json';
  final String pagosFile = 'assets/data/pagos.json';

  @override
  void onInit() {
    super.onInit();
    cargarDatos();
    //cargarLugaresDisponibles();
    //cargarVehiculosUsuario();

  }
  Future<void> crearReserva({
    required LugarDisponible lugarSeleccionado,
    required double duracionHoras,
    required String vehiculo,
    }) async {
      final DateTime inicio = DateTime.now();
      final DateTime fin = inicio.add(Duration(hours: duracionHoras.toInt()));
      final double precio = lugarSeleccionado.precioPorHora * duracionHoras;

      final nuevaReserva = Reserva(
        id: 'resv_${DateTime.now().millisecondsSinceEpoch}', // Usa string si tu modelo usa String
        lugar: lugarSeleccionado,
        vehiculo: vehiculo,
        fechaHoraInicio: inicio,
        fechaHoraFin: fin,
        precio: precio,
        estado: EstadoReserva.activa,
      );

      // Aquí puedes agregar lógica para guardar la reserva en tu lista o persistencia
      reservas.add(nuevaReserva);
      await guardarReservas();
      update();
    }

  Future<void> pagarReservaActual(Reserva reserva, String metodoPago) async {
    final reservaPagada = reserva.copyWith(
      estado: EstadoReserva.completada,
      metodoPago: metodoPago,
    );

    // Reemplaza la reserva antigua por la nueva
    final index = reservas.indexWhere((r) => r.id == reserva.id);
    if (index != -1) {
      reservas[index] = reservaPagada;
      await guardarReservas(); // Asegúrate de tener este método para persistir
      update(); // Si usas GetX
    }
  }

  Future<void> cargarDatos() async {
  try {
    await cargarReservas();
  } catch (e, stack) {
    print('Error al cargar reservas: $e');
    print(stack);
  }

  try {
    await cargarLugares();
  } catch (e, stack) {
    print('Error al cargar lugares: $e');
    print(stack);
  }

  try {
    await cargarPagos();
  } catch (e, stack) {
    print('Error al cargar pagos: $e');
    print(stack);
  }
}


  Future<File> _getLocalFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<void> cargarReservas() async {
    final file = await _getLocalFile('reservas.json');
    if (await file.exists()) {
      final contenido = await file.readAsString();
      final data = jsonDecode(contenido) as List;
      reservas.value = data.map((e) => Reserva.fromJson(e,lugaresDisponibles)).toList();
      
    } else {
      final contenido = await rootBundle.loadString(reservasFile);
      final data = jsonDecode(contenido) as List;
      reservas.value = data.map((e) => Reserva.fromJson(e,lugaresDisponibles)).toList();
    }
  }
  void agregarReserva(Reserva nuevaReserva) {
    reservas.add(nuevaReserva);
    // opcional: actualizar estados, persistir datos, notificar UI, etc.
    update(); // si usas GetX para notificar cambios
  }
  Future<void> guardarReservas() async {
    final file = await _getLocalFile('reservas.json');
    await file.writeAsString(jsonEncode(reservas.map((e) => e.toJson()).toList()));
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

  Future<void> registrarPago(Reserva reserva, String metodoPago) async {
    final nuevoPago = Pago(
      id: pagos.length + 1,
      reservaId: int.parse(reserva.id),
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
        estado: EstadoReserva.completada, // si aplica como "pagado"
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


}
