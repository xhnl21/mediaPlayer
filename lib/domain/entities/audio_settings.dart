import 'package:equatable/equatable.dart';

class AudioSettings extends Equatable {
  const AudioSettings({
    this.loremIpsum1 = true,
    this.dolorSitAmet = false,
    this.consecteturAdipiscing = true,
    this.loremIpsum2 = false,
  });

  final bool loremIpsum1;
  final bool dolorSitAmet;
  final bool consecteturAdipiscing;
  final bool loremIpsum2;

  AudioSettings copyWith({
    bool? loremIpsum1,
    bool? dolorSitAmet,
    bool? consecteturAdipiscing,
    bool? loremIpsum2,
  }) {
    return AudioSettings(
      loremIpsum1: loremIpsum1 ?? this.loremIpsum1,
      dolorSitAmet: dolorSitAmet ?? this.dolorSitAmet,
      consecteturAdipiscing:
          consecteturAdipiscing ?? this.consecteturAdipiscing,
      loremIpsum2: loremIpsum2 ?? this.loremIpsum2,
    );
  }

  @override
  List<Object?> get props => [
    loremIpsum1,
    dolorSitAmet,
    consecteturAdipiscing,
    loremIpsum2,
  ];
}
