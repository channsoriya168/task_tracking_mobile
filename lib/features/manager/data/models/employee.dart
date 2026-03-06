export 'package:task_tracking_mobile/features/manager/data/models/position.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final String positionId;
  final String? imagePath;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? phone;
  final String? userId;
  final String? qrCode;
  final DateTime? qrExpiresAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.positionId,
    this.imagePath,
    this.dateOfBirth,
    this.placeOfBirth,
    this.phone,
    this.userId,
    this.qrCode,
    this.qrExpiresAt,
  });

  bool get hasQr => qrCode != null && qrCode!.isNotEmpty;
  bool get isQrExpired =>
      hasQr && qrExpiresAt != null && qrExpiresAt!.isBefore(DateTime.now());
  bool get isQrActive => hasQr && !isQrExpired;

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? positionId,
    String? imagePath,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? phone,
    String? userId,
    String? qrCode,
    DateTime? qrExpiresAt,
    bool clearQrCode = false,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      positionId: positionId ?? this.positionId,
      imagePath: imagePath ?? this.imagePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      qrCode: clearQrCode ? null : (qrCode ?? this.qrCode),
      qrExpiresAt: clearQrCode ? null : (qrExpiresAt ?? this.qrExpiresAt),
    );
  }
}

// ── Mock Data ─────────────────────────────────────────────────

final List<Employee> kMockEmployees = [
  const Employee(
    id: 'e1',
    name: 'Alice Johnson',
    email: 'alice@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e2',
    name: 'Bob Smith',
    email: 'bob@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e3',
    name: 'Charlie Brown',
    email: 'charlie@company.com',
    positionId: 'p1',
  ),
  const Employee(
    id: 'e4',
    name: 'Diana Prince',
    email: 'diana@company.com',
    positionId: 'p2',
  ),
  const Employee(
    id: 'e5',
    name: 'Eve Davis',
    email: 'eve@company.com',
    positionId: 'p2',
  ),
  const Employee(
    id: 'e6',
    name: 'Frank Miller',
    email: 'frank@company.com',
    positionId: 'p3',
  ),
  const Employee(
    id: 'e7',
    name: 'Grace Lee',
    email: 'grace@company.com',
    positionId: 'p3',
  ),
  const Employee(
    id: 'e8',
    name: 'Henry Wilson',
    email: 'henry@company.com',
    positionId: 'p4',
  ),
  const Employee(
    id: 'e9',
    name: 'Isabella Chen',
    email: 'isabella@company.com',
    positionId: 'p4',
  ),
  const Employee(
    id: 'e10',
    name: 'James Taylor',
    email: 'james@company.com',
    positionId: 'p1',
  ),
];
