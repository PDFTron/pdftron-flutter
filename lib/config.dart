part of pdftron;

/// A class to contain the viewer configuration options.
///
/// The class properties represent all possible viewer configuration options.
/// These options are not required and have default values. For more information on
/// these configurations, look at the [GitHub API documentation](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep-nullsafe/doc/api/API.md).
class Config {
  var _disabledElements;
  var _disabledTools;
  var _multiTabEnabled;
  var _customHeaders;
  var _fitMode;
  var _layoutMode;
  var _initialPageNumber;
  var _isBase64String;
  var _base64FileExtension;
  var _hideThumbnailFilterModes;
  var _longPressMenuEnabled;
  var _longPressMenuItems;
  var _overrideLongPressMenuBehavior;
  var _hideAnnotationMenu;
  var _annotationMenuItems;
  var _overrideAnnotationMenuBehavior;
  var _exportPath;
  var _openUrlPath;
  var _autoSaveEnabled;
  var _pageChangeOnTap;
  var _showSavedSignatures;
  var _useStylusAsPen;
  var _signSignatureFieldWithStamps;
  var _selectAnnotationAfterCreation;
  var _pageIndicatorEnabled;
  var _followSystemDarkMode;
  var _annotationToolbars;
  var _hideDefaultAnnotationToolbars;
  var _hideAnnotationToolbarSwitcher;
  var _hideTopToolbars;
  var _hideTopAppNavBar;
  var _hideBottomToolbar;
  var _showLeadingNavButton;
  var _readOnly;
  var _thumbnailViewEditingEnabled;
  var _annotationAuthor;
  var _continuousAnnotationEditing;
  var _annotationPermissionCheckEnabled;
  var _overrideBehavior;
  var _tabTitle;
  var _pageNumberIndicatorAlwaysVisible;

  Config();

  /// A list of [Buttons] that will be disabled in the viewer.
  ///
  /// Defaults to empty.
  set disabledElements(List value) => _disabledElements = value;

  /// A list of [Tools] that will be disabled in the viewer.
  ///
  /// Defaults to empty.
  set disabledTools(List value) => _disabledTools = value;

  /// Whether tabs will be used to facilitate the viewing of multiple documents
  /// simultaneously.
  ///
  /// If this value is true and [PdftronFlutter.openDocument(document)] is called, it
  /// will open a new tab with the associated document. Defaults to false.
  set multiTabEnabled(bool value) => _multiTabEnabled = value;

  /// The custom headers to use with HTTP/HTTPS requests.
  ///
  /// Defaults to empty.
  set customHeaders(Map<String, String> value) => _customHeaders = value;

  /// The default zoom level of the viewer.
  ///
  /// Can be set with one of the [FitModes] constants. Defaults to [FitModes.fitWidth].
  set fitMode(String value) => _fitMode = value;

  /// The layout mode of the viewer.
  ///
  /// Can be set with one of the [LayoutModes] constants. Defaults to
  /// [LayoutModes.continuous].
  set layoutMode(String value) => _layoutMode = value;

  /// The initial page number upon opening a document.
  ///
  /// Page numbers are 1-indexed.
  set initialPageNumber(int value) => _initialPageNumber = value;

  /// Whether to treat the document in [PdftronFlutter.openDocument(document)] as a base64 string.
  ///
  /// Defaults to false.
  set isBase64String(bool value) => _isBase64String = value;

  /// If _isBase64String is true, it defines the file extension to use.
  ///
  /// Defaults to ".pdf" but is required if using the base64 string of a non-pdf file.
  set base64FileExtension(String value) => _base64FileExtension = value;

  /// A list of [ThumbnailFilterModes] that will be hidden in the thumbnails browser.
  ///
  /// Defaults to empty.
  set hideThumbnailFilterModes(List value) => _hideThumbnailFilterModes = value;

  /// Whether to show a popup menu after the user long presses on text or blank space.
  ///
  /// Defaults to true.
  set longPressMenuEnabled(bool value) => _longPressMenuEnabled = value;

  /// A list of [LongPressMenuItems] that can be shown after long pressing on text
  /// or blank space.
  ///
  /// Defaults to all of [LongPressMenuItems].
  set longPressMenuItems(List value) => _longPressMenuItems = value;

  /// The long press menu items that will skip default beahaviour when pressed.
  ///
  /// These menu items will still be displayed in the long press menu.
  /// The new behaviour is defined in the [startLongPressMenuPressedListener()].
  /// Defaults to empty.
  set overrideLongPressMenuBehavior(List value) =>
      _overrideLongPressMenuBehavior = value;

  /// A list of [Tools] that will not show in the default annotation menu.
  ///
  /// Defaults to empty.
  set hideAnnotationMenu(List value) => _hideAnnotationMenu = value;

  /// A list of [AnnotationMenuItems] that will show when an annotation is selected.
  ///
  /// Defaults to all of [AnnotationMenuItems].
  set annotationMenuItems(List value) => _annotationMenuItems = value;

  /// A list of [AnnotationMenuItems] that will skip default behaviour when pressed.
  ///
  /// These menu items will still be displayed in the annotation menu.
  /// The new behaviour will be defined in the [startAnnotationMenuPressedListener()].
  /// Defaults to empty.
  set overrideAnnotationMenuBehavior(List value) =>
      _overrideAnnotationMenuBehavior = value;

  /// Where a file is saved when using actions such as: "save a password copy",
  /// "save a flattened copy", etc.
  ///
  /// Defaults to null.
  set exportPath(String value) => _exportPath = value;

  /// Where a cache file is saved when opening files from HTTPS.
  ///
  /// Defaults to null.
  set openUrlPath(String value) => _openUrlPath = value;

  /// Whether the document is automatically saved.
  ///
  /// Defaults to true.
  set autoSaveEnabled(bool value) => _autoSaveEnabled = value;

  /// If in a horizontal viewing mode, whether the viewer changes pages when a users
  /// taps the page's edge.
  ///
  /// Defaults to true.
  set pageChangeOnTap(bool value) => _pageChangeOnTap = value;

  /// Whether to show saved signatures for re-use.
  ///
  /// Defaults to true.
  set showSavedSignatures(bool value) => _showSavedSignatures = value;

  /// Whether a stylus should act like a pen when the viewer is in pan mode.
  ///
  /// If false, it will act like a finger. Defaults to true.
  set useStylusAsPen(bool value) => _useStylusAsPen;

  /// Whether signature fields will be signed with image stamps.
  ///
  /// Defaults to false.
  set signSignatureFieldWithStamps(bool value) =>
      _signSignatureFieldWithStamps = value;

  /// Whether the annotation is selected after creation.
  ///
  /// On iOS, this functions for shape and text markup only. Defaults to true.
  set selectAnnotationAfterCreation(bool value) =>
      _selectAnnotationAfterCreation = value;

  /// Whehter to show the page indicator.
  ///
  /// Defaults to true.
  set pageIndicatorEnabled(bool value) => _pageIndicatorEnabled = value;

  /// If the system is in dark mode, whether to have the UI will appear in a dark color.
  ///
  /// Android only. Defaults to true.
  set followSystemDarkMode(bool value) => _followSystemDarkMode = value;

  /// A list of [CustomToolbar] objects or [DefaultToolbars] constants that define a
  /// custom toolbar.
  ///
  /// If used the default toolbar no longer shows. Defualts to empty.
  set annotationToolbars(List value) => _annotationToolbars = value;

  /// A list of [DefaultToolbars] that defines the default annotation toolbars to hide
  ///
  /// It should not be used in conjunction with [annotationToolbars]. Defaults to empty.
  set hideDefaultAnnotationToolbars(List value) =>
      _hideDefaultAnnotationToolbars = value;

  /// Whether to show the toolbar switcher in the top toolbar.
  ///
  /// Defaults to false.
  set hideAnnotationToolbarSwitcher(bool value) =>
      _hideAnnotationToolbarSwitcher = value;

  /// Whether to hide both the top app navigation bar and the annotation toolbar.
  ///
  /// Defaults to false.
  set hideTopToolbars(bool value) => _hideTopToolbars = value;

  /// Whether to hide the top app navigation bar.
  ///
  /// Defaults to false.
  set hideTopAppNavBar(bool value) => _hideTopAppNavBar = value;

  /// Whether to hide the bottom toolbar for the current viewer.
  ///
  /// Defaults to false.
  set hideBottomToolbar(bool value) => _hideBottomToolbar = value;

  /// Whether to show the leading navigation button.
  ///
  /// Defaults to true.
  set showLeadingNavButton(bool value) => _showLeadingNavButton = value;

  /// Whether the viewer allows users to edit the document.
  ///
  /// Defaults to false.
  set readOnly(bool value) => _readOnly = value;

  /// Whether the user can edit the document from the thumbnail view.
  ///
  /// Defaults to true.
  set thumbnailViewEditingEnabled(bool value) =>
      _thumbnailViewEditingEnabled = value;

  /// The author name for all annotations created on the current document.
  ///
  /// When the xfdfCommand is exported, this information is included.
  set annotationAuthor(String value) => _annotationAuthor = value;

  /// Whether the active annotation creation tool will remain the current annotation
  /// tool.
  ///
  /// Defaults to true.
  set continuousAnnotationEditing(bool value) =>
      _continuousAnnotationEditing = value;

  /// Whether the annotation's flags will be considered upon its selection.
  ///
  /// E.g. An annotation with a locked flag cannot be resized or moved.
  ///
  /// Defaults to false.
  set annotationPermissionCheckEnabled(bool value) =>
      _annotationPermissionCheckEnabled = value;

  /// A list of [Behaviors] that can skip their default behaviour e.g. external link clicking.
  ///
  /// The new behaviour will be defined in [startBehaviorActivatedListener()].
  /// Defaults to empty.
  set overrideBehavior(List<String> value) => _overrideBehavior = value;

  /// If [multiTabEnabled] is true, sets the tab title.
  ///
  /// For Android, it is only supported on the [DocumentView] widget.
  /// Defaults to the file name.
  set tabTitle(String value) => _tabTitle = value;

  /// Whether the page indicator is always visible.
  ///
  /// Defaults to false.
  set pageNumberIndicatorAlwaysVisible(bool value) =>
      _pageNumberIndicatorAlwaysVisible = value;

  Config.fromJson(Map<String, dynamic> json)
      : _disabledElements = json['disabledElements'],
        _disabledTools = json['disabledTools'],
        _multiTabEnabled = json['multiTabEnabled'],
        _customHeaders = json['customHeaders'],
        _fitMode = json['fitMode'],
        _layoutMode = json['layoutMode'],
        _initialPageNumber = json['initialPageNumber'],
        _isBase64String = json['isBase64String'],
        _base64FileExtension = json['base64FileExtension'],
        _hideThumbnailFilterModes = json['hideThumbnailFilterModes'],
        _longPressMenuEnabled = json['longPressMenuEnabled'],
        _longPressMenuItems = json['longPressMenuItems'],
        _overrideLongPressMenuBehavior = json['overrideLongPressMenuBehavior'],
        _hideAnnotationMenu = json['hideAnnotationMenu'],
        _annotationMenuItems = json['annotationMenuItems'],
        _overrideAnnotationMenuBehavior =
            json['overrideAnnotationMenuBehavior'],
        _exportPath = json['exportPath'],
        _openUrlPath = json['openUrlPath'],
        _autoSaveEnabled = json['autoSaveEnabled'],
        _pageChangeOnTap = json['pageChangeOnTap'],
        _showSavedSignatures = json['showSavedSignatures'],
        _useStylusAsPen = json['useStylusAsPen'],
        _signSignatureFieldWithStamps = json['signSignatureFieldWithStamps'],
        _selectAnnotationAfterCreation = json['selectAnnotationAfterCreation'],
        _pageIndicatorEnabled = json['pageIndicatorEnabled'],
        _followSystemDarkMode = json['followSystemDarkMode'],
        _annotationToolbars = json['annotationToolbars'],
        _hideDefaultAnnotationToolbars = json['hideDefaultAnnotationToolbars'],
        _hideAnnotationToolbarSwitcher = json['hideAnnotationToolbarSwitcher'],
        _hideTopToolbars = json['hideTopToolbars'],
        _hideTopAppNavBar = json['hideTopAppNavBar'],
        _hideBottomToolbar = json['hideBottomToolbar'],
        _showLeadingNavButton = json['showLeadingNavButton'],
        _readOnly = json['readOnly'],
        _thumbnailViewEditingEnabled = json['thumbnailViewEditingEnabled'],
        _annotationAuthor = json['annotationAuthor'],
        _continuousAnnotationEditing = json['continuousAnnotationEditing'],
        _annotationPermissionCheckEnabled =
            json['annotationPermissionCheckEnabled'],
        _overrideBehavior = json['overrideBehavior'],
        _tabTitle = json['tabTitle'],
        _pageNumberIndicatorAlwaysVisible =
            json['pageNumberIndicatorAlwaysVisible'];

  Map<String, dynamic> toJson() => {
        'disabledElements': _disabledElements,
        'disabledTools': _disabledTools,
        'multiTabEnabled': _multiTabEnabled,
        'customHeaders': _customHeaders,
        'fitMode': _fitMode,
        'layoutMode': _layoutMode,
        'initialPageNumber': _initialPageNumber,
        'isBase64String': _isBase64String,
        'base64FileExtension': _base64FileExtension,
        'hideThumbnailFilterModes': _hideThumbnailFilterModes,
        'longPressMenuEnabled': _longPressMenuEnabled,
        'longPressMenuItems': _longPressMenuItems,
        'overrideLongPressMenuBehavior': _overrideLongPressMenuBehavior,
        'hideAnnotationMenu': _hideAnnotationMenu,
        'annotationMenuItems': _annotationMenuItems,
        'overrideAnnotationMenuBehavior': _overrideAnnotationMenuBehavior,
        'exportPath': _exportPath,
        'openUrlPath': _openUrlPath,
        'autoSaveEnabled': _autoSaveEnabled,
        'pageChangeOnTap': _pageChangeOnTap,
        'showSavedSignatures': _showSavedSignatures,
        'useStylusAsPen': _useStylusAsPen,
        'signSignatureFieldWithStamps': _signSignatureFieldWithStamps,
        'selectAnnotationAfterCreation': _selectAnnotationAfterCreation,
        'pageIndicatorEnabled': _pageIndicatorEnabled,
        'followSystemDarkMode': _followSystemDarkMode,
        'annotationToolbars': _annotationToolbars,
        'hideDefaultAnnotationToolbars': _hideDefaultAnnotationToolbars,
        'hideAnnotationToolbarSwitcher': _hideAnnotationToolbarSwitcher,
        'hideTopToolbars': _hideTopToolbars,
        'hideTopAppNavBar': _hideTopAppNavBar,
        'hideBottomToolbar': _hideBottomToolbar,
        'showLeadingNavButton': _showLeadingNavButton,
        'readOnly': _readOnly,
        'thumbnailViewEditingEnabled': _thumbnailViewEditingEnabled,
        'annotationAuthor': _annotationAuthor,
        'continuousAnnotationEditing': _continuousAnnotationEditing,
        'annotationPermissionCheckEnabled': _annotationPermissionCheckEnabled,
        'overrideBehavior': _overrideBehavior,
        'tabTitle': _tabTitle,
        'pageNumberIndicatorAlwaysVisible': _pageNumberIndicatorAlwaysVisible,
      };
}
