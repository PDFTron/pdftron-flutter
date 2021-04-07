// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeText _$FreeTextFromJson(Map<String, dynamic> json) {
  return FreeText(
    json['rect'] == null ? null : Rect.fromJson(json['rect']),
    json['pageNumber'] as int,
  )
    ..id = json['id'] as String
    ..borderStyleObject = json['borderStyleObject'] == null
        ? null
        : BorderStyleObject.fromJson(
            json['borderStyleObject'] as Map<String, dynamic>)
    ..rotation = json['rotation'] as int
    ..customData = (json['customData'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..contents = json['contents'] as String
    ..color = colorFromJSON(json['color'] as Map<String, double>)
    ..markup = json['markup'] as bool
    ..title = json['title'] as String
    ..subject = json['subject'] as String
    ..opacity = (json['opacity'] as num)?.toDouble()
    ..borderEffect = json['borderEffect'] as String
    ..borderEffectIntensity = (json['borderEffectIntensity'] as num)?.toDouble()
    ..interiorColor =
        colorFromJSON(json['interiorColor'] as Map<String, double>)
    ..contentRect =
        json['contentRect'] == null ? null : Rect.fromJson(json['contentRect'])
    ..paddingRect =
        json['paddingRect'] == null ? null : Rect.fromJson(json['paddingRect'])
    ..markupType = json['markupType'] as String
    ..quaddingFormat = json['quaddingFormat'] as String
    ..intentName = json['intentName'] as String
    ..textColor = colorFromJSON(json['textColor'] as Map<String, double>)
    ..lineColor = colorFromJSON(json['lineColor'] as Map<String, double>)
    ..fontSize = (json['fontSize'] as num)?.toDouble();
}

Map<String, dynamic> _$FreeTextToJson(FreeText instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('rect', instance.rect);
  writeNotNull('pageNumber', instance.pageNumber);
  writeNotNull('borderStyleObject', instance.borderStyleObject);
  writeNotNull('rotation', instance.rotation);
  writeNotNull('customData', instance.customData);
  writeNotNull('contents', instance.contents);
  writeNotNull('color', colorToJSON(instance.color));
  writeNotNull('markup', instance.markup);
  writeNotNull('title', instance.title);
  writeNotNull('subject', instance.subject);
  writeNotNull('opacity', instance.opacity);
  writeNotNull('borderEffect', instance.borderEffect);
  writeNotNull('borderEffectIntensity', instance.borderEffectIntensity);
  writeNotNull('interiorColor', colorToJSON(instance.interiorColor));
  writeNotNull('contentRect', instance.contentRect);
  writeNotNull('paddingRect', instance.paddingRect);
  writeNotNull('markupType', instance.markupType);
  writeNotNull('quaddingFormat', instance.quaddingFormat);
  writeNotNull('intentName', instance.intentName);
  writeNotNull('textColor', colorToJSON(instance.textColor));
  writeNotNull('lineColor', colorToJSON(instance.lineColor));
  writeNotNull('fontSize', instance.fontSize);
  return val;
}

BorderStyleObject _$BorderStyleObjectFromJson(Map<String, dynamic> json) {
  return BorderStyleObject(
    json['style'] as String,
    (json['horizontalCornerRadius'] as num)?.toDouble(),
    (json['verticalCornerRadius'] as num)?.toDouble(),
    (json['width'] as num)?.toDouble(),
    (json['dashPattern'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
  );
}

Map<String, dynamic> _$BorderStyleObjectToJson(BorderStyleObject instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('style', instance.style);
  writeNotNull('horizontalCornerRadius', instance.horizontalCornerRadius);
  writeNotNull('verticalCornerRadius', instance.verticalCornerRadius);
  writeNotNull('width', instance.width);
  writeNotNull('dashPattern', instance.dashPattern);
  return val;
}
