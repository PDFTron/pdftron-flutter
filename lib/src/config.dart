import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable(includeIfNull: false)
class Config {
  List<String> disabledElements;
  List<String> disabledTools;
  bool multiTabEnabled;
  Map<String, String> customHeaders;
  String fitMode;
  String layoutMode;
  int initialPageNumber;
  bool isBase64String;
  String base64FileExtension;
  List<String> hideThumbnailFilterModes;
  bool longPressMenuEnabled;
  List<String> longPressMenuItems;
  List<String> overrideLongPressMenuBehavior;
  bool hideAnnotationMenu;
  List<String> annotationMenuItems;
  List<String> overrideAnnotationMenuBehavior;
  bool autoSaveEnabled;
  bool pageChangeOnTap;
  bool showSavedSignatures;
  bool useStylusAsPen;
  bool signSignatureFieldWithStamps;
  bool selectAnnotationAfterCreation;
  bool pageIndicatorEnabled;
  bool followSystemDarkMode;
  List<dynamic> annotationToolbars;
  List<String> hideDefaultAnnotationToolbars;
  bool hideAnnotationToolbarSwitcher;
  bool hideTopToolbars;
  bool hideTopAppNavBar;
  bool hideBottomToolbar;
  bool showLeadingNavButton;
  bool readOnly;
  bool thumbnailViewEditingEnabled;
  String annotationAuthor;
  bool continuousAnnotationEditing;
  bool annotationPermissionCheckEnabled;
  String overrideBehavior;
  String tabTitle;

  Config();

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
