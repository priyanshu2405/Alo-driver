part of 'model.dart';


@JsonSerializable()
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  @JsonKey(name: "phone_no")
  final String? phoneNo;
  final String? address;
  @JsonKey(name: "country_code")
  final String? countryCode;

  UserModel({
    this.phoneNo,
    this.name,
    this.email,
    this.id,
    this.address,
    this.countryCode,
  });

  factory UserModel.fromJson(JsonMap json) => _$UserModelFromJson(json);

  JsonMap toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class TermsAndCondition {
  final String? description;

  TermsAndCondition({this.description});

  factory TermsAndCondition.fromJson(JsonMap json) =>
      _$TermsAndConditionFromJson(json);

  JsonMap toJson() => _$TermsAndConditionToJson(this);
}
