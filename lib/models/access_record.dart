class AccessRecord {
  final String user;
  final DateTime dateTime;
  final bool success;
  final String origin;

  const AccessRecord({
    required this.user,
    required this.dateTime,
    required this.success,
    this.origin = 'Web',
  });

  Map<String, dynamic> toJson() => {
    'usuario': user,
    'fechaHora': dateTime.toIso8601String(),
    'resultado': success ? 'AUTORIZADO' : 'RECHAZADO',
    'origen': origin,
  };

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
    return AccessRecord(
      user: json['usuario'] as String,
      dateTime: DateTime.parse(json['fechaHora'] as String),
      success: json['resultado'] == 'AUTORIZADO',
      origin: json['origen'] as String? ?? 'Web',
    );
  }
}
