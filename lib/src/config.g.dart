// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return Config()
    ..disabledElements =
        (json['disabledElements'] as List)?.map((e) => e as String)?.toList()
    ..disabledTools =
        (json['disabledTools'] as List)?.map((e) => e as String)?.toList()
    ..multiTabEnabled = json['multiTabEnabled'] as bool
    ..customHeaders = (json['customHeaders'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    )
    ..fitMode = json['fitMode'] as String
    ..layoutMode = json['layoutMode'] as String
    ..initialPageNumber = json['initialPageNumber'] as int
    ..isBase64String = json['isBase64String'] as bool
    ..base64FileExtension = json['base64FileExtension'] as String
    ..hideThumbnailFilterModes = (json['hideThumbnailFilterModes'] as List)
        ?.map((e) => e as String)
        ?.toList()
    ..longPressMenuEnabled = json['longPressMenuEnabled'] as bool
    ..longPressMenuItems =
        (json['longPressMenuItems'] as List)?.map((e) => e as String)?.toList()
    ..overrideLongPressMenuBehavior =
        (json['overrideLongPressMenuBehavior'] as List)
            ?.map((e) => e as String)
            ?.toList()
    ..hideAnnotationMenu = json['hideAnnotationMenu'] as bool
    ..annotationMenuItems =
        (json['annotationMenuItems'] as List)?.map((e) => e as String)?.toList()
    ..overrideAnnotationMenuBehavior =
        (json['overrideAnnotationMenuBehavior'] as List)
            ?.map((e) => e as String)
            ?.toList()
    ..autoSaveEnabled = json['autoSaveEnabled'] as bool
    ..pageChangeOnTap = json['pageChangeOnTap'] as bool
    ..showSavedSignatures = json['showSavedSignatures'] as bool
    ..useStylusAsPen = json['useStylusAsPen'] as bool
    ..signSignatureFieldWithStamps =
        json['signSignatureFieldWithStamps'] as bool
    ..selectAnnotationAfterCreation =
        json['selectAnnotationAfterCreation'] as bool
    ..pageIndicatorEnabled = json['pageIndicatorEnabled'] as bool
    ..followSystemDarkMode = json['followSystemDarkMode'] as bool
    ..annotationToolbars = json['annotationToolbars'] as List
    ..hideDefaultAnnotationToolbars =
        (json['hideDefaultAnnotationToolbars'] as List)
            ?.map((e) => e as String)
            ?.toList()
    ..hideAnnotationToolbarSwitcher =
        json['hideAnnotationToolbarSwitcher'] as bool
    ..hideTopToolbars = json['hideTopToolbars'] as bool
    ..hideTopAppNavBar = json['hideTopAppNavBar'] as bool
    ..hideBottomToolbar = json['hideBottomToolbar'] as bool
    ..showLeadingNavButton = json['showLeadingNavButton'] as bool
    ..readOnly = json['readOnly'] as bool
    ..thumbnailViewEditingEnabled = json['thumbnailViewEditingEnabled'] as bool
    ..annotationAuthor = json['annotationAuthor'] as String
    ..continuousAnnotationEditing = json['continuousAnnotationEditing'] as bool
    ..annotationPermissionCheckEnabled =
        json['annotationPermissionCheckEnabled'] as bool
    ..overrideBehavior = json['overrideBehavior'] as String
    ..tabTitle = json['tabTitle'] as String;
}

Map<String, dynamic> _$ConfigToJson(Config instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('disabledElements', instance.disabledElements);
  writeNotNull('disabledTools', instance.disabledTools);
  writeNotNull('multiTabEnabled', instance.multiTabEnabled);
  writeNotNull('customHeaders', instance.customHeaders);
  writeNotNull('fitMode', instance.fitMode);
  writeNotNull('layoutMode', instance.layoutMode);
  writeNotNull('initialPageNumber', instance.initialPageNumber);
  writeNotNull('isBase64String', instance.isBase64String);
  writeNotNull('base64FileExtension', instance.base64FileExtension);
  writeNotNull('hideThumbnailFilterModes', instance.hideThumbnailFilterModes);
  writeNotNull('longPressMenuEnabled', instance.longPressMenuEnabled);
  writeNotNull('longPressMenuItems', instance.longPressMenuItems);
  writeNotNull(
      'overrideLongPressMenuBehavior', instance.overrideLongPressMenuBehavior);
  writeNotNull('hideAnnotationMenu', instance.hideAnnotationMenu);
  writeNotNull('annotationMenuItems', instance.annotationMenuItems);
  writeNotNull('overrideAnnotationMenuBehavior',
      instance.overrideAnnotationMenuBehavior);
  writeNotNull('autoSaveEnabled', instance.autoSaveEnabled);
  writeNotNull('pageChangeOnTap', instance.pageChangeOnTap);
  writeNotNull('showSavedSignatures', instance.showSavedSignatures);
  writeNotNull('useStylusAsPen', instance.useStylusAsPen);
  writeNotNull(
      'signSignatureFieldWithStamps', instance.signSignatureFieldWithStamps);
  writeNotNull(
      'selectAnnotationAfterCreation', instance.selectAnnotationAfterCreation);
  writeNotNull('pageIndicatorEnabled', instance.pageIndicatorEnabled);
  writeNotNull('followSystemDarkMode', instance.followSystemDarkMode);
  writeNotNull('annotationToolbars', instance.annotationToolbars);
  writeNotNull(
      'hideDefaultAnnotationToolbars', instance.hideDefaultAnnotationToolbars);
  writeNotNull(
      'hideAnnotationToolbarSwitcher', instance.hideAnnotationToolbarSwitcher);
  writeNotNull('hideTopToolbars', instance.hideTopToolbars);
  writeNotNull('hideTopAppNavBar', instance.hideTopAppNavBar);
  writeNotNull('hideBottomToolbar', instance.hideBottomToolbar);
  writeNotNull('showLeadingNavButton', instance.showLeadingNavButton);
  writeNotNull('readOnly', instance.readOnly);
  writeNotNull(
      'thumbnailViewEditingEnabled', instance.thumbnailViewEditingEnabled);
  writeNotNull('annotationAuthor', instance.annotationAuthor);
  writeNotNull(
      'continuousAnnotationEditing', instance.continuousAnnotationEditing);
  writeNotNull('annotationPermissionCheckEnabled',
      instance.annotationPermissionCheckEnabled);
  writeNotNull('overrideBehavior', instance.overrideBehavior);
  writeNotNull('tabTitle', instance.tabTitle);
  return val;
}
