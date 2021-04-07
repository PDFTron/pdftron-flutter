import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'options.dart';

part 'annotation.g.dart';
/*
  This file is for function addAnnotations.
*/

/* 
  The class for all annotations. rect and pageNumber are required when initialized
*/
abstract class Annotation {
  String id; // the unique id of the annotation
  Rect rect; // the rectangle area around the annotation
  int pageNumber; // the page in which the annotation exists (1-indexed)
  BorderStyleObject
      borderStyleObject; // border style for the annotation. Typically used for Link annotations.
  int rotation; // rotation (in degrees) for the annotation. Should be multiples of 90
  Map<String, String>
      customData; // custom data to be associated with the annotation
  String contents; // contents of the annotation
  @JsonKey(fromJson: colorFromJSON, toJson: colorToJSON)
  Color color; // color of the annotation
  bool
      markup; // whether this is a markup annotation. Should not be set externally

  Annotation(this.rect, this.pageNumber);
}

/* 
  The class for all markup annotations. rect and pageNumber are required when initialized
*/
abstract class Markup extends Annotation {
  String title; // title of the markup
  String subject; // subject of the markup
  double
      opacity; // opacity of the markup, between [0, 1]. 1 is the default value, meaning 100% visible
  String
      borderEffect; // border effect of the markup. Should be an AnnotationBorderEffect constant
  double
      borderEffectIntensity; // Intensity for the border effect, between [0, 2]. 0 is the default value
  @JsonKey(fromJson: colorFromJSON, toJson: colorToJSON)
  Color interiorColor; // Interior color of the markup
  Rect contentRect; // the content rectangle area of the markup
  Rect
      paddingRect; // the paddings describing the difference between the rect and the actual boundary
  String
      markupType; // which type of markup annotation. Should not be set externally

  Markup(Rect rect, int pageNumber) : super(rect, pageNumber) {
    markup = true;
  }
}

/* 
  The class for FreeText annotation. rect and pageNumber are required when initialized
*/
@JsonSerializable(includeIfNull: false)
class FreeText extends Markup {
  String
      quaddingFormat; // quadding format of the FreeText. should be a FreeTextQuaddingFormat constant. Left-justified by default
  String
      intentName; // intent of the FreeText. should be a FreeTextIntentName constant
  @JsonKey(fromJson: colorFromJSON, toJson: colorToJSON)
  Color textColor; // text color of the FreeText
  @JsonKey(fromJson: colorFromJSON, toJson: colorToJSON)
  Color lineColor; // line color of the FreeText
  double fontSize; // font size of the FreeText

  FreeText(Rect rect, int pageNumber) : super(rect, pageNumber) {
    markupType = 'freeText';
  }

  factory FreeText.fromJson(Map<String, dynamic> json) =>
      _$FreeTextFromJson(json);

  Map<String, dynamic> toJson() => _$FreeTextToJson(this);
}

/* 
  The class for border styles. all but dashPattern are required when initialized
*/

@JsonSerializable(includeIfNull: false)
class BorderStyleObject {
  String
      style; // style type of the border. Should be an AnnotationBorderStyle constant
  double horizontalCornerRadius; // horizontal corner radius of the border
  double verticalCornerRadius; // vertical corner radius of the border
  double width; // width of the border
  List<double> dashPattern; // dashPattern of the border

  BorderStyleObject(this.style, this.horizontalCornerRadius,
      this.verticalCornerRadius, this.width,
      [this.dashPattern]);

  factory BorderStyleObject.fromJson(Map<String, dynamic> json) =>
      _$BorderStyleObjectFromJson(json);

  Map<String, dynamic> toJson() => _$BorderStyleObjectToJson(this);
}

/* 
  A customized JSON string conversion from Color
*/
Map<String, double> colorToJSON(Color color) {
  if (color == null) {
    return null;
  }

  double red = color.red / 255;
  double green = color.green / 255;
  double blue = color.blue / 255;

  Map<String, double> colorMap = {
    'red': red,
    'green': green,
    'blue': blue,
  };

  return colorMap;
}

Color colorFromJSON(Map<String, double> colorMap) {
  int red = (colorMap['red'] * 255) as int;
  int green = (colorMap['green'] * 255) as int;
  int blue = (colorMap['blue'] * 255) as int;

  return new Color.fromRGBO(red, green, blue, 1.0);
}
