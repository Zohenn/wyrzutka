import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_vote_dto.freezed.dart';

@freezed
class UpdateVoteDto with _$UpdateVoteDto {
  const factory UpdateVoteDto(Map<String, bool> votes, int balance) = Vote;
  const factory UpdateVoteDto.verified() = Verified;
}