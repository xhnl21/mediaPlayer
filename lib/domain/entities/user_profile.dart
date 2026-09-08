import 'package:equatable/equatable.dart';
import 'package:media_player/domain/value_objects/email_address.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.statusMessage = 'Dolor sit amet \n Hicius 25489',
    this.avatarUrl,
  });

  final String id;
  final String name;
  final EmailAddress email;
  final String phone;
  final String statusMessage;
  final String? avatarUrl;

  UserProfile copyWith({
    String? id,
    String? name,
    EmailAddress? email,
    String? phone,
    String? statusMessage,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      statusMessage: statusMessage ?? this.statusMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, statusMessage, avatarUrl];
}
