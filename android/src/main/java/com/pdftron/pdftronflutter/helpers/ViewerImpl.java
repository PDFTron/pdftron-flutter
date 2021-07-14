package com.pdftron.pdftronflutter.helpers;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pdftron.pdf.Action;
import com.pdftron.pdf.ActionParameter;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.Field;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.annots.Widget;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.tools.QuickMenu;
import com.pdftron.pdf.tools.QuickMenuItem;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.ActionUtils;
import com.pdftron.sdf.Obj;
import com.pdftron.pdf.utils.AnnotUtils;
import com.pdftron.pdf.utils.ViewerUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

import static com.pdftron.pdftronflutter.helpers.PluginUtils.BEHAVIOR_LINK_PRESS;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ACTION;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_DATA;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LINK_BEHAVIOR_DATA;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_LIST;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_MENU_ITEM;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LONG_PRESS_MENU_ITEM;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_LONG_PRESS_TEXT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_PAGE_NUMBER;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_PREVIOUS_PAGE_NUMBER;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.checkQuickMenu;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.convStringToAnnotType;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.getAnnotationsData;

public class ViewerImpl {

    private ViewerComponent mViewerComponent;

    public ViewerImpl(@NonNull ViewerComponent component) {
        mViewerComponent = component;
    }

    public void addListeners(@NonNull ToolManager toolManager) {
        toolManager.addAnnotationModificationListener(mAnnotationModificationListener);
        toolManager.addAnnotationsSelectionListener(mAnnotationsSelectionListener);
        toolManager.addPdfDocModificationListener(mPdfDocModificationListener);
    }

    public void addListeners(@NonNull PdfViewCtrlTabFragment2 pdfViewCtrlTabFragment) {
        pdfViewCtrlTabFragment.addQuickMenuListener(mQuickMenuListener);
    }

    public void addListeners(@NonNull PDFViewCtrl pdfViewCtrl) {
        pdfViewCtrl.addOnCanvasSizeChangeListener(mOnCanvasSizeChangedListener);
        pdfViewCtrl.addPageChangeListener(mPageChangedListener);
    }

    public void removeListeners(@NonNull ToolManager toolManager) {
        toolManager.removeAnnotationModificationListener(mAnnotationModificationListener);
        toolManager.removeAnnotationsSelectionListener(mAnnotationsSelectionListener);
        toolManager.removePdfDocModificationListener(mPdfDocModificationListener);
    }

    public void removeListeners(@NonNull PdfViewCtrlTabFragment2 pdfViewCtrlTabFragment) {
        pdfViewCtrlTabFragment.removeQuickMenuListener(mQuickMenuListener);
    }

    public void removeListeners(@NonNull PDFViewCtrl pdfViewCtrl) {
        pdfViewCtrl.removeOnCanvasSizeChangeListener(mOnCanvasSizeChangedListener);
        pdfViewCtrl.removePageChangeListener(mPageChangedListener);
    }

    public void setActionInterceptCallback() {
        ActionUtils.getInstance().setActionInterceptCallback(mActionInterceptCallback);
    }


    private ToolManager.AnnotationModificationListener mAnnotationModificationListener = new ToolManager.AnnotationModificationListener() {
        @Override
        public void onAnnotationsAdded(Map<Annot, Integer> map) {
            PluginUtils.emitAnnotationChangedEvent(PluginUtils.KEY_ACTION_ADD, map, mViewerComponent);

            PluginUtils.emitExportAnnotationCommandEvent(PluginUtils.KEY_ACTION_ADD, map, mViewerComponent);
        }

        @Override
        public void onAnnotationsPreModify(Map<Annot, Integer> map) {
        }

        @Override
        public void onAnnotationsModified(Map<Annot, Integer> map, Bundle bundle) {
            PluginUtils.emitAnnotationChangedEvent(PluginUtils.KEY_ACTION_MODIFY, map, mViewerComponent);

            PluginUtils.emitExportAnnotationCommandEvent(PluginUtils.KEY_ACTION_MODIFY, map, mViewerComponent);

            JSONArray fieldsArray = new JSONArray();

            for (Annot annot : map.keySet()) {
                try {
                    if (annot != null && annot.isValid() && annot.getType() == Annot.e_Widget) {

                        String fieldName = null, fieldValue = null;

                        Widget widget = new Widget(annot);
                        Field field = widget.getField();
                        if (field != null) {
                            fieldName = field.getName();
                            fieldValue = field.getValueAsString();
                        }

                        if (fieldName != null && fieldValue != null) {
                            JSONObject fieldObject = new JSONObject();
                            fieldObject.put(PluginUtils.KEY_FIELD_NAME, fieldName);
                            fieldObject.put(PluginUtils.KEY_FIELD_VALUE, fieldValue);
                            fieldsArray.put(fieldObject);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            EventChannel.EventSink eventSink = mViewerComponent.getFormFieldValueChangedEventEmitter();
            if (eventSink != null) {
                eventSink.success(fieldsArray.toString());
            }
        }

        @Override
        public void onAnnotationsPreRemove(Map<Annot, Integer> map) {
            PluginUtils.emitAnnotationChangedEvent(PluginUtils.KEY_ACTION_DELETE, map, mViewerComponent);

            PluginUtils.emitExportAnnotationCommandEvent(PluginUtils.KEY_ACTION_DELETE, map, mViewerComponent);
        }

        @Override
        public void onAnnotationsRemoved(Map<Annot, Integer> map) {

        }

        @Override
        public void onAnnotationsRemovedOnPage(int i) {

        }

        @Override
        public void annotationsCouldNotBeAdded(String s) {

        }
    };

    private ToolManager.AnnotationsSelectionListener mAnnotationsSelectionListener = new ToolManager.AnnotationsSelectionListener() {
        @Override
        public void onAnnotationsSelectionChanged(HashMap<Annot, Integer> hashMap) {
            PluginUtils.emitAnnotationsSelectedEvent(hashMap, mViewerComponent);
        }
    };

    private ToolManager.PdfDocModificationListener mPdfDocModificationListener = new ToolManager.PdfDocModificationListener() {
        @Override
        public void onBookmarkModified() {
            String bookmarkJson = null;
            try {
                bookmarkJson = PluginUtils.generateBookmarkJson(mViewerComponent);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            EventChannel.EventSink eventSink = mViewerComponent.getExportBookmarkEventEmitter();
            if (eventSink != null) {
                eventSink.success(bookmarkJson);
            }
        }

        @Override
        public void onPagesCropped() {

        }

        @Override
        public void onPagesAdded(List<Integer> list) {

        }

        @Override
        public void onPagesDeleted(List<Integer> list) {

        }

        @Override
        public void onPagesRotated(List<Integer> list) {

        }

        @Override
        public void onPageMoved(int from, int to) {
            EventChannel.EventSink eventSink = mViewerComponent.getPageMovedEventEmitter();
            if (eventSink != null) {
                JSONObject resultObject = new JSONObject();
                try {
                    resultObject.put(KEY_PREVIOUS_PAGE_NUMBER, from);
                    resultObject.put(KEY_PAGE_NUMBER, to);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                eventSink.success(resultObject.toString());
            }
        }

        @Override
        public void onPageLabelsChanged() {

        }

        @Override
        public void onAllAnnotationsRemoved() {

        }

        @Override
        public void onAnnotationAction() {

        }
    };

    private ActionUtils.ActionInterceptCallback mActionInterceptCallback = new ActionUtils.ActionInterceptCallback() {
        @Override
        public boolean onInterceptExecuteAction(ActionParameter actionParameter, PDFViewCtrl pdfViewCtrl) {
            ArrayList<String> actionOverrideItems = mViewerComponent.getActionOverrideItems();
            if (actionOverrideItems == null || !actionOverrideItems.contains(BEHAVIOR_LINK_PRESS)) {
                return false;
            }

            String url = null;
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;

                Action action = actionParameter.getAction();
                int action_type = action.getType();
                if (action_type == Action.e_URI) {
                    Obj o = action.getSDFObj();
                    o = o.findObj("URI");
                    if (o != null) {
                        url = o.getAsPDFText();
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
            if (url != null) {
                try {
                    JSONObject behaviorObject = new JSONObject();

                    behaviorObject.put(KEY_ACTION, BEHAVIOR_LINK_PRESS);

                    JSONObject dataObject = new JSONObject();
                    dataObject.put(KEY_LINK_BEHAVIOR_DATA, url);

                    behaviorObject.put(KEY_DATA, dataObject);

                    EventChannel.EventSink eventSink = mViewerComponent.getBehaviorActivatedEventEmitter();
                    if (eventSink != null) {
                        eventSink.success(behaviorObject.toString());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return true;
            }
            return false;
        }
    };

    private ToolManager.QuickMenuListener mQuickMenuListener = new ToolManager.QuickMenuListener() {
        @Override
        public boolean onQuickMenuClicked(QuickMenuItem quickMenuItem) {
            String menuStr = PluginUtils.convQuickMenuIdToString(quickMenuItem.getItemId());

            // check if this is an override menu
            boolean result = false;

            if (mViewerComponent.getPdfViewCtrl() != null && mViewerComponent.getToolManager() != null) {

                // If annotations are selected - annotationMenu; Or: - longPressMenu
                if (PluginUtils.hasAnnotationsSelected(mViewerComponent)) {
                    if (mViewerComponent.getAnnotationMenuOverrideItems() != null) {
                        result = mViewerComponent.getAnnotationMenuOverrideItems().contains(menuStr);
                    }

                    try {
                        JSONObject annotationMenuObject = new JSONObject();
                        annotationMenuObject.put(KEY_ANNOTATION_MENU_ITEM, menuStr);
                        annotationMenuObject.put(KEY_ANNOTATION_LIST, getAnnotationsData(mViewerComponent));

                        EventChannel.EventSink eventSink = mViewerComponent.getAnnotationMenuPressedEventEmitter();
                        if (eventSink != null) {
                            eventSink.success(annotationMenuObject.toString());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    if (mViewerComponent.getLongPressMenuOverrideItems() != null) {
                        result = mViewerComponent.getLongPressMenuOverrideItems().contains(menuStr);
                    }

                    try {
                        JSONObject longPressMenuObject = new JSONObject();
                        longPressMenuObject.put(KEY_LONG_PRESS_MENU_ITEM, menuStr);
                        longPressMenuObject.put(KEY_LONG_PRESS_TEXT, ViewerUtils.getSelectedString(mViewerComponent.getPdfViewCtrl()));

                        EventChannel.EventSink eventSink = mViewerComponent.getLongPressMenuPressedEventEmitter();
                        if (eventSink != null) {
                            eventSink.success(longPressMenuObject.toString());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }

            return result;
        }

        @Override
        public boolean onShowQuickMenu(QuickMenu quickMenu, @Nullable Annot annot) {
            if (mViewerComponent.getHideAnnotationMenuTools() != null && annot != null && mViewerComponent.getPdfViewCtrl() != null) {
                for (String tool : mViewerComponent.getHideAnnotationMenuTools()) {
                    int type = convStringToAnnotType(tool);
                    boolean shouldUnlockRead = false;
                    try {
                        mViewerComponent.getPdfViewCtrl().docLockRead();
                        shouldUnlockRead = true;

                        int annotType = AnnotUtils.getAnnotType(annot);
                        if (annotType == type) {
                            mViewerComponent.getPdfViewCtrl().docUnlockRead();
                            return true;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (shouldUnlockRead) {
                            mViewerComponent.getPdfViewCtrl().docUnlockRead();
                        }
                    }
                }
            }

            // remove unwanted items
            if (mViewerComponent.getAnnotationMenuItems() != null && annot != null) {
                List<QuickMenuItem> removeList = new ArrayList<>();
                checkQuickMenu(quickMenu.getFirstRowMenuItems(), mViewerComponent.getAnnotationMenuItems(), removeList);
                checkQuickMenu(quickMenu.getSecondRowMenuItems(), mViewerComponent.getAnnotationMenuItems(), removeList);
                checkQuickMenu(quickMenu.getOverflowMenuItems(), mViewerComponent.getAnnotationMenuItems(), removeList);
                quickMenu.removeMenuEntries(removeList);

                if (quickMenu.getFirstRowMenuItems().size() == 0) {
                    quickMenu.setDividerVisibility(View.GONE);
                }
            }
            if (mViewerComponent.getLongPressMenuItems() != null && null == annot) {
                List<QuickMenuItem> removeList = new ArrayList<>();
                checkQuickMenu(quickMenu.getFirstRowMenuItems(), mViewerComponent.getLongPressMenuItems(), removeList);
                checkQuickMenu(quickMenu.getSecondRowMenuItems(), mViewerComponent.getLongPressMenuItems(), removeList);
                checkQuickMenu(quickMenu.getOverflowMenuItems(), mViewerComponent.getLongPressMenuItems(), removeList);
                quickMenu.removeMenuEntries(removeList);

                if (quickMenu.getFirstRowMenuItems().size() == 0) {
                    quickMenu.setDividerVisibility(View.GONE);
                }
            }
            return false;
        }

        @Override
        public void onQuickMenuShown() {

        }

        @Override
        public void onQuickMenuDismissed() {

        }
    };

    private PDFViewCtrl.OnCanvasSizeChangeListener mOnCanvasSizeChangedListener = new PDFViewCtrl.OnCanvasSizeChangeListener() {
        @Override
        public void onCanvasSizeChanged() {
            EventChannel.EventSink eventSink = mViewerComponent.getZoomChangedEventEmitter();
            if (eventSink != null && mViewerComponent.getPdfViewCtrl() != null) {
                eventSink.success(mViewerComponent.getPdfViewCtrl().getZoom());
            }
        }
    };

    private PDFViewCtrl.PageChangeListener mPageChangedListener = new PDFViewCtrl.PageChangeListener() {
        @Override
        public void onPageChange(int old_page, int cur_page, PDFViewCtrl.PageChangeState pageChangeState) {
            EventChannel.EventSink eventSink = mViewerComponent.getPageChangedEventEmitter();
            if (eventSink != null && (old_page != cur_page || pageChangeState == PDFViewCtrl.PageChangeState.END)) {
                JSONObject resultObject = new JSONObject();
                try {
                    resultObject.put(KEY_PREVIOUS_PAGE_NUMBER, old_page);
                    resultObject.put(KEY_PAGE_NUMBER, cur_page);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                eventSink.success(resultObject.toString());
            }
        }
    };
}
