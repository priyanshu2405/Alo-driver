// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  phoneNo: json['phone_no'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  id: (json['id'] as num?)?.toInt(),
  address: json['address'] as String?,
  countryCode: json['country_code'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone_no': instance.phoneNo,
  'address': instance.address,
  'country_code': instance.countryCode,
};

TermsAndCondition _$TermsAndConditionFromJson(Map<String, dynamic> json) =>
    TermsAndCondition(description: json['description'] as String?);

Map<String, dynamic> _$TermsAndConditionToJson(TermsAndCondition instance) =>
    <String, dynamic>{'description': instance.description};
