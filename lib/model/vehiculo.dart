class Vehiculo {
  final String id;
  final String placa;
  final String marca;
  final String modelo;
  final String color;
  
  Vehiculo({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.color,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) => Vehiculo(
    id: json['id'] ?? '',
    placa: json['placa'] ?? '',
    marca: json['marca'] ?? '',
    modelo: json['modelo'] ?? '',
    color: json['color'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'placa': placa,
    'marca': marca,
    'modelo': modelo,
    'color': color,
  };
}