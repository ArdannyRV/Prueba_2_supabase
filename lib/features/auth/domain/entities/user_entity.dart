import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final String? rol;
  final bool debeCambiarPass;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.rol,
    this.debeCambiarPass = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt, rol, debeCambiarPass];
}
