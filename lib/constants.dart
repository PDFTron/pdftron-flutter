part of pdftron;

// Functions define the names of the functions
class Functions {
  static const getPlatformVersion = "getPlatformVersion";
  static const getVersion = "getVersion";
  static const initialize = "initialize";
  static const openDocument = "openDocument";
  static const importAnnotations = "importAnnotations";
  static const exportAnnotations = "exportAnnotations";
  static const flattenAnnotations = "flattenAnnotations";
  static const deleteAnnotations = "deleteAnnotations";
  static const selectAnnotation = "selectAnnotation";
  static const setFlagsForAnnotations = "setFlagsForAnnotations";
  static const setPropertiesForAnnotation = "setPropertiesForAnnotation";
  static const importAnnotationCommand = "importAnnotationCommand";
  static const importBookmarkJson = "importBookmarkJson";
  static const saveDocument = "saveDocument";
  static const commitTool = "commitTool";
  static const getPageCount = "getPageCount";
  static const handleBackButton = "handleBackButton";
  static const getPageCropBox = "getPageCropBox";
  static const getPageRotation = "getPageRotation";
  static const setCurrentPage = "setCurrentPage";
  static const getDocumentPath = "getDocumentPath";
  static const setToolMode = "setToolMode";
  static const setValuesForFields = "setValuesForFields";
  static const setFlagForFields = "setFlagForFields";
  static const setLeadingNavButtonIcon = "setLeadingNavButtonIcon";
  static const closeAllTabs = "closeAllTabs";
  static const deleteAllAnnotations = "deleteAllAnnotations";
  static const exportAsImage = "exportAsImage";
  static const exportAsImageFromFilePath = "exportAsImageFromFilePath";
}

// Parameters define the parameters of the functions
class Parameters {
  static const licenseKey = "licenseKey";
  static const document = "document";
  static const password = "password";
  static const config = "config";
  static const xfdfCommand = "xfdfCommand";
  static const xfdf = "xfdf";
  static const bookmarkJson = "bookmarkJson";
  static const pageNumber = "pageNumber";
  static const toolMode = "toolMode";
  static const fieldNames = "fieldNames";
  static const fields = "fields";
  static const flag = "flag";
  static const flagValue = "flagValue";
  static const formsOnly = "formsOnly";
  static const annotations = "annotations";
  static const annotation = "annotation";
  static const annotationsWithFlags = "annotationsWithFlags";
  static const annotationProperties = "annotationProperties";
  static const leadingNavButtonIcon = "leadingNavButtonIcon";
  static const path = "path";
  static const exportFormat = "exportFormat";
  static const dpi = "dpi";
}

// Parameters define the parameters of the events
class EventParameters {
  static const action = "action";
  static const annotations = "annotations";
  static const xfdfCommand = "xfdfCommand";
  static const data = "data";
  static const longPressMenuItem = "longPressMenuItem";
  static const longPressText = "longPressText";
  static const annotationMenuItem = "annotationMenuItem";
  static const previousPageNumber = "previousPageNumber";
  static const pageNumber = "pageNumber";
}

// Buttons define the various kinds of buttons for the viewer
class Buttons {
  static const viewControlsButton = 'viewControlsButton';
  static const freeHandToolButton = 'freeHandToolButton';
  static const highlightToolButton = 'highlightToolButton';
  static const underlineToolButton = 'underlineToolButton';
  static const squigglyToolButton = 'squigglyToolButton';
  static const strikeoutToolButton = 'strikeoutToolButton';
  static const rectangleToolButton = 'rectangleToolButton';
  static const ellipseToolButton = 'ellipseToolButton';
  static const lineToolButton = 'lineToolButton';
  static const arrowToolButton = 'arrowToolButton';
  static const polylineToolButton = 'polylineToolButton';
  static const polygonToolButton = 'polygonToolButton';
  static const cloudToolButton = 'cloudToolButton';
  static const signatureToolButton = 'signatureToolButton';
  static const freeTextToolButton = 'freeTextToolButton';
  static const stickyToolButton = 'stickyToolButton';
  static const calloutToolButton = 'calloutToolButton';
  static const stampToolButton = 'stampToolButton';
  static const toolsButton = 'toolsButton';
  static const searchButton = 'searchButton';
  static const shareButton = 'shareButton';
  static const thumbnailsButton = 'thumbnailsButton';
  static const listsButton = 'listsButton';
  static const thumbnailSlider = 'thumbnailSlider';
  static const saveCopyButton = 'saveCopyButton';
  static const editPagesButton = 'editPagesButton';
  static const printButton = 'printButton';
  static const closeButton = 'closeButton';
  static const fillAndSignButton = 'fillAndSignButton';
  static const prepareFormButton = 'prepareFormButton';
  static const outlineListButton = 'outlineListButton';
  static const annotationListButton = 'annotationListButton';
  static const userBookmarkListButton = 'userBookmarkListButton';
  static const reflowModeButton = 'reflowModeButton';
  static const editMenuButton = 'editMenuButton';
  static const cropPageButton = 'cropPageButton';
  static const moreItemsButton = 'moreItemsButton';
  static const eraserButton = 'eraserButton';
  static const undo = 'undo';
  static const redo = 'redo';

  // Android only
  static const editAnnotationToolbarButton = 'editAnnotationToolButton';
}

// Tools define the various kinds of tools for the viewer
class Tools {
  static const annotationEdit = 'AnnotationEdit';
  static const textSelect = 'TextSelect';
  static const annotationCreateSticky = 'AnnotationCreateSticky';
  static const annotationCreateFreeHand = 'AnnotationCreateFreeHand';
  static const annotationCreateTextHighlight = 'AnnotationCreateTextHighlight';
  static const annotationCreateTextUnderline = 'AnnotationCreateTextUnderline';
  static const annotationCreateTextSquiggly = 'AnnotationCreateTextSquiggly';
  static const annotationCreateTextStrikeout = 'AnnotationCreateTextStrikeout';
  static const annotationCreateFreeText = 'AnnotationCreateFreeText';
  static const annotationCreateCallout = 'AnnotationCreateCallout';
  static const annotationCreateSignature = 'AnnotationCreateSignature';
  static const annotationCreateLine = 'AnnotationCreateLine';
  static const annotationCreateArrow = 'AnnotationCreateArrow';
  static const annotationCreatePolyline = 'AnnotationCreatePolyline';
  static const annotationCreateStamp = 'AnnotationCreateStamp';
  static const annotationCreateRectangle = 'AnnotationCreateRectangle';
  static const annotationCreateEllipse = 'AnnotationCreateEllipse';
  static const annotationCreatePolygon = 'AnnotationCreatePolygon';
  static const annotationCreatePolygonCloud = 'AnnotationCreatePolygonCloud';
  static const annotationCreateDistanceMeasurement =
      'AnnotationCreateDistanceMeasurement';
  static const annotationCreatePerimeterMeasurement =
      'AnnotationCreatePerimeterMeasurement';
  static const annotationCreateAreaMeasurement =
      'AnnotationCreateAreaMeasurement';
  static const annotationCreateRectangleAreaMeasurement =
      'AnnotationCreateRectangleAreaMeasurement';
  static const annotationCreateSound = 'AnnotationCreateSound';
  static const annotationCreateFreeHighlighter =
      'AnnotationCreateFreeHighlighter';
  static const annotationCreateRubberStamp = 'AnnotationCreateRubberStamp';
  static const eraser = 'Eraser';
  static const annotationCreateFileAttachment =
      'AnnotationCreateFileAttachment';
  static const annotationCreateRedaction = 'AnnotationCreateRedaction';
  static const annotationCreateLink = 'AnnotationCreateLink';
  static const annotationCreateRedactionText = 'AnnotationCreateRedactionText';
  static const annotationCreateLinkText = 'AnnotationCreateLinkText';
  static const formCreateTextField = 'FormCreateTextField';
  static const formCreateCheckboxField = 'FormCreateCheckboxField';
  static const formCreateSignatureField = 'FormCreateSignatureField';
  static const formCreateRadioField = 'FormCreateRadioField';
  static const formCreateComboBoxField = 'FormCreateComboBoxField';
  static const formCreateListBoxField = 'FormCreateListBoxField';

  // iOS only.
  static const pencilKitDrawing = 'PencilKitDrawing';

  // Android only.
  static const annotationSmartPen = 'AnnotationSmartPen';
  static const annotationLasso = 'AnnotationLasso';
}

// FitModes define all fit modes in the viewer
class FitModes {
  static const fitPage = 'FitPage';
  static const fitWidth = 'FitWidth';
  static const fitHeight = 'FitHeight';
  static const zoom = 'Zoom';
}

// LayoutModes define all layout modes in the viewer
class LayoutModes {
  static const single = 'Single';
  static const continuous = 'Continuous';
  static const facing = 'Facing';
  static const facingContinuous = 'FacingContinuous';
  static const facingCover = 'FacingCover';
  static const facingCoverContinuous = 'FacingCoverContinuous';
}

// FieldFlags define the property flags for a form field
class FieldFlags {
  static const ReadOnly = 0;
  static const Required = 1;
}

// ThumbnailFilterModes define the filter modes in thumbnail browser
class ThumbnailFilterModes {
  static const annotated = "annotated";
  static const bookmarked = "bookmarked";
}

// AnnotationFlags define the flags for any annotation in the document
class AnnotationFlags {
  static const hidden = "hidden";
  static const invisible = "invisible";
  static const locked = "locked";
  static const lockedContents = "lockedContents";
  static const noRotate = "noRotate";
  static const noView = "noView";
  static const noZoom = "noZoom";
  static const print = "print";
  static const readOnly = "readOnly";
  static const toggleNoView = "toggleNoView";
}

// AnnotationProperties define all possible annotation properties
class AnnotationProperties {
  // not markup exclusive
  static const rect = "rect";
  static const contents = "contents";
  // markup exclusive
  static const subject = "subject";
  static const title = "title";
  static const contentRect = "contentRect";
  static const rotation = "rotation";
}

// Behaviors define all user behaviors in the viewer
class Behaviors {
  static const linkPress = "linkPress";
}

// LongPressMenuItems define all menu items that could show up on long press of text or empty area
class LongPressMenuItems {
  static const copy = "copy";
  static const search = "search";
  static const share = "share";
  static const read = "read";
}

// AnnotationMenuItems define all menu items that could show up on press of annotation
class AnnotationMenuItems {
  static const style = "style";
  static const note = "note";
  static const copy = "copy";
  static const delete = "delete";
  static const flatten = "flatten";
  static const editText = "editText";
  static const editInk = "editInk";
  static const search = "search";
  static const share = "share";
  static const markupType = "markupType";
  static const read = "read";
  static const screenCapture = "screenCapture";
  static const playSound = "playSound";
  static const openAttachment = "openAttachment";
  static const calibrate = "calibrate";
}

// DefaultToolbars define a set of pre-designed toolbars for easier customization
class DefaultToolbars {
  static const view = "PDFTron_View";
  static const annotate = "PDFTron_Annotate";
  static const draw = "PDFTron_Draw";
  static const insert = "PDFTron_Insert";
  static const fillAndSign = "PDFTron_Fill_and_Sign";
  static const prepareForm = "PDFTron_Prepare_Form";
  static const measure = "PDFTron_Measure";
  static const pens = "PDFTron_Pens";
  static const redaction = "PDFTron_Redact";
  static const favorite = "PDFTron_Favorite";
}

// ToolbarIcons define default toolbar icons for use for potential custom toolbars
class ToolbarIcons {
  static const view = "PDFTron_View";
  static const annotate = "PDFTron_Annotate";
  static const draw = "PDFTron_Draw";
  static const insert = "PDFTron_Insert";
  static const fillAndSign = "PDFTron_Fill_and_Sign";
  static const prepareForm = "PDFTron_Prepare_Form";
  static const measure = "PDFTron_Measure";
  static const pens = "PDFTron_Pens";
  static const redaction = "PDFTron_Redact";
  static const favorite = "PDFTron_Favorite";
}

  class ExportFormat {
    static const BMP = "BMP";
    static const JPEG =  "JPEG";
    static const PNG = "PNG";
  }
