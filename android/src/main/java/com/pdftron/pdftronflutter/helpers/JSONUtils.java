package com.pdftron.pdftronflutter.helpers;

import com.pdftron.common.PDFNetException;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.ColorPt;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.Page;
import com.pdftron.pdf.Rect;
import com.pdftron.pdf.annots.FreeText;
import com.pdftron.pdf.annots.Markup;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.UUID;

import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_BORDER_STYLE_OBJECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_COLOR;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_CONTENTS;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_CUSTOM_DATA;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_ID;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_MARKUP;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_PAGE_NUMBER;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_RECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_ANNOTATION_ROTATION;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_EFFECT_CLOUDY;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_EFFECT_NONE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_BEVELED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_DASHED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_INSET;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_OBJECT_DASH_PATTERN;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_OBJECT_HORIZONTAL_CORNER_RADIUS;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_OBJECT_VERTICAL_CORNER_RADIUS;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_OBJECT_WIDTH;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_SOLID;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_BORDER_STYLE_UNDERLINE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_COLOR_BLUE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_COLOR_GREEN;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_COLOR_RED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_FREE_TEXT_ANNOTATION_FONT_SIZE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_FREE_TEXT_ANNOTATION_INTENT_NAME;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_FREE_TEXT_ANNOTATION_LINE_COLOR;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_FREE_TEXT_ANNOTATION_QUADDING_FORMAT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_FREE_TEXT_ANNOTATION_TEXT_COLOR;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_INTENT_NAME_FREE_TEXT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_INTENT_NAME_FREE_TEXT_CALLOUT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_INTENT_NAME_FREE_TEXT_TYPE_WRITER;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_BORDER_EFFECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_BORDER_EFFECT_INTENSITY;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_CONTENT_RECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_INTERIOR_COLOR;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_OPACITY;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_PADDING_RECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_SUBJECT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_TITLE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_TYPE;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_MARKUP_TYPE_FREE_TEXT;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_QUADDING_FORMAT_CENTERED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_QUADDING_FORMAT_LEFT_JUSTIFIED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_QUADDING_FORMAT_RIGHT_JUSTIFIED;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_X1;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_X2;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_Y1;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.KEY_Y2;
import static com.pdftron.pdftronflutter.helpers.PluginUtils.NUMBER_COLOR_SPACE;

public class JSONUtils {

    public static Annot getAnnotationFromJSONObject(JSONObject annotJSONObject, PDFDoc pdfDoc) throws JSONException, PDFNetException {
        if (annotJSONObject == null || !areJSONKeysValid(annotJSONObject, KEY_ANNOTATION_PAGE_NUMBER, KEY_ANNOTATION_RECT, KEY_ANNOTATION_MARKUP)) {
            return null;
        }

        int currAnnotPageNumber = annotJSONObject.getInt(KEY_ANNOTATION_PAGE_NUMBER);

        Page page = pdfDoc.getPage(currAnnotPageNumber);

        if (page == null || !page.isValid()) {
            return null;
        }

        boolean markup = annotJSONObject.getBoolean(KEY_ANNOTATION_MARKUP);

        Annot annot;

        if (markup) {
            annot = getMarkupFromJSONObject(annotJSONObject, pdfDoc);
            if (annot == null) {
                return null;
            }
        } else {
            return null;
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_ID)) {
            String id = annotJSONObject.getString(KEY_ANNOTATION_ID);
            annot.setUniqueID(id);
        } else {
            annot.setUniqueID(UUID.randomUUID().toString());
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_BORDER_STYLE_OBJECT)) {
            JSONObject borderStyleObject = getJSONObjectFromJSONObject(annotJSONObject, KEY_ANNOTATION_BORDER_STYLE_OBJECT);
            Annot.BorderStyle borderStyle = getBorderStyleObjectFromJSONObject(borderStyleObject);

            if (borderStyle != null) {
                annot.setBorderStyle(borderStyle);
            }
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_ROTATION)) {
            int rotation = annotJSONObject.getInt(KEY_ANNOTATION_ROTATION);
            annot.setRotation(rotation);
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_CUSTOM_DATA)) {
            JSONObject customDataObject = getJSONObjectFromJSONObject(annotJSONObject, KEY_ANNOTATION_CUSTOM_DATA);
            Map<String, String> customData = getMapFromJSONObject(customDataObject);

            for (String key : customData.keySet()) {
                annot.setCustomData(key, customData.get(key));
            }
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_CONTENTS)) {
            String contents = annotJSONObject.getString(KEY_ANNOTATION_CONTENTS);
            annot.setContents(contents);
        }

        if (isJSONKeyValid(annotJSONObject, KEY_ANNOTATION_COLOR)) {
            JSONObject colorObject = getJSONObjectFromJSONObject(annotJSONObject, KEY_ANNOTATION_COLOR);
            ColorPt color = getColorPtFromJSONObject(colorObject);

            if (color != null) {
                annot.setColor(color, NUMBER_COLOR_SPACE);
            }
        }

        annot.setPage(page);

        return annot;
    }

    private static Markup getMarkupFromJSONObject(JSONObject currAnnotJSONObject, PDFDoc pdfDoc) throws PDFNetException, JSONException {
        Markup markupAnnot;

        if (!isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_TYPE)) {
            return null;
        }

        switch (currAnnotJSONObject.getString(KEY_MARKUP_TYPE)) {
            case KEY_MARKUP_TYPE_FREE_TEXT:
                markupAnnot = getFreeTextFromJSONObject(currAnnotJSONObject, pdfDoc);
                if (markupAnnot == null) {
                    return null;
                }
                break;
            default:
                return null;
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_TITLE)) {
            String title = currAnnotJSONObject.getString(KEY_MARKUP_TITLE);
            markupAnnot.setTitle(title);
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_SUBJECT)) {
            String subject = currAnnotJSONObject.getString(KEY_MARKUP_SUBJECT);
            markupAnnot.setSubject(subject);
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_OPACITY)) {
            double opacity = currAnnotJSONObject.getDouble(KEY_MARKUP_OPACITY);
            markupAnnot.setOpacity(opacity);
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_BORDER_EFFECT)) {
            String borderEffectString = currAnnotJSONObject.getString(KEY_MARKUP_BORDER_EFFECT);
            switch (borderEffectString) {
                case KEY_BORDER_EFFECT_NONE:
                    markupAnnot.setBorderEffect(Markup.e_None);
                    break;
                case KEY_BORDER_EFFECT_CLOUDY:
                    markupAnnot.setBorderEffect(Markup.e_Cloudy);
                    break;
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_BORDER_EFFECT_INTENSITY)) {
            double borderEffectIntensity = currAnnotJSONObject.getDouble(KEY_MARKUP_BORDER_EFFECT_INTENSITY);
            markupAnnot.setBorderEffectIntensity(borderEffectIntensity);
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_INTERIOR_COLOR)) {
            JSONObject colorObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_MARKUP_INTERIOR_COLOR);
            ColorPt interiorColor = getColorPtFromJSONObject(colorObject);

            if (interiorColor != null) {
                markupAnnot.setInteriorColor(interiorColor, NUMBER_COLOR_SPACE);
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_CONTENT_RECT)) {
            JSONObject rectObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_MARKUP_CONTENT_RECT);
            Rect contentRect = getRectFromJSONObject(rectObject);

            if (contentRect != null) {
                markupAnnot.setContentRect(contentRect);
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_MARKUP_PADDING_RECT)) {
            JSONObject rectObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_MARKUP_PADDING_RECT);
            Rect paddingRect = getRectFromJSONObject(rectObject);

            if (paddingRect != null) {
                markupAnnot.setPadding(paddingRect);
            }
        }

        return markupAnnot;
    }

    private static FreeText getFreeTextFromJSONObject(JSONObject currAnnotJSONObject, PDFDoc pdfDoc) throws PDFNetException, JSONException {

        JSONObject rectObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_ANNOTATION_RECT);
        Rect rect = getRectFromJSONObject(rectObject);

        if (rect == null) {
            return null;
        }

        FreeText freeTextAnnot = FreeText.create(pdfDoc, rect);

        if (isJSONKeyValid(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_QUADDING_FORMAT)) {
            String quaddingFormatString = currAnnotJSONObject.getString(KEY_FREE_TEXT_ANNOTATION_QUADDING_FORMAT);
            switch (quaddingFormatString) {
                case KEY_QUADDING_FORMAT_LEFT_JUSTIFIED:
                    freeTextAnnot.setQuaddingFormat(0);
                    break;
                case KEY_QUADDING_FORMAT_CENTERED:
                    freeTextAnnot.setQuaddingFormat(1);
                    break;
                case KEY_QUADDING_FORMAT_RIGHT_JUSTIFIED:
                    freeTextAnnot.setQuaddingFormat(2);
                    break;
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_INTENT_NAME)) {
            String intentNameString = currAnnotJSONObject.getString(KEY_FREE_TEXT_ANNOTATION_INTENT_NAME);
            switch (intentNameString) {
                case KEY_INTENT_NAME_FREE_TEXT:
                    freeTextAnnot.setIntentName(FreeText.e_FreeText);
                    break;
                case KEY_INTENT_NAME_FREE_TEXT_CALLOUT:
                    freeTextAnnot.setIntentName(FreeText.e_FreeTextCallout);
                    break;
                case KEY_INTENT_NAME_FREE_TEXT_TYPE_WRITER:
                    freeTextAnnot.setIntentName(FreeText.e_FreeTextTypeWriter);
                    break;
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_TEXT_COLOR)) {
            JSONObject colorObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_TEXT_COLOR);
            ColorPt textColor = getColorPtFromJSONObject(colorObject);

            if (textColor != null) {
                freeTextAnnot.setTextColor(textColor, NUMBER_COLOR_SPACE);
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_LINE_COLOR)) {
            JSONObject colorObject = getJSONObjectFromJSONObject(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_LINE_COLOR);
            ColorPt lineColor = getColorPtFromJSONObject(colorObject);

            if (lineColor != null) {
                freeTextAnnot.setLineColor(lineColor, NUMBER_COLOR_SPACE);
            }
        }

        if (isJSONKeyValid(currAnnotJSONObject, KEY_FREE_TEXT_ANNOTATION_FONT_SIZE)) {
            double fontSize = currAnnotJSONObject.getDouble(KEY_FREE_TEXT_ANNOTATION_FONT_SIZE);
            freeTextAnnot.setFontSize(fontSize);
        }

        return freeTextAnnot;
    }

    public static Rect getRectFromJSONObject(JSONObject object) throws PDFNetException, JSONException {
        if (!areJSONKeysValid(object, KEY_X1, KEY_Y1, KEY_X2, KEY_Y2)) {
            return null;
        }

        double x1 = object.getDouble(KEY_X1);
        double y1 = object.getDouble(KEY_Y1);
        double x2 = object.getDouble(KEY_X2);
        double y2 = object.getDouble(KEY_Y2);

        return new Rect(x1, y1, x2, y2);
    }

    private static Map<String, String> getMapFromJSONObject(JSONObject object) throws JSONException {
        Map<String, String> map = new HashMap<>();

        Iterator<String> keyIterator = object.keys();
        while (keyIterator.hasNext()) {
            String key = keyIterator.next();
            map.put(key, object.getString(key));
        }

        return map;
    }

    private static Annot.BorderStyle getBorderStyleObjectFromJSONObject(JSONObject object) throws PDFNetException, JSONException {
        if (!areJSONKeysValid(object, KEY_BORDER_STYLE, KEY_BORDER_STYLE_OBJECT_HORIZONTAL_CORNER_RADIUS,
                KEY_BORDER_STYLE_OBJECT_VERTICAL_CORNER_RADIUS, KEY_BORDER_STYLE_OBJECT_WIDTH)) {
            return null;
        }

        int style;
        switch (object.getString(KEY_BORDER_STYLE)) {
            case KEY_BORDER_STYLE_SOLID:
                style = Annot.BorderStyle.e_solid;
                break;
            case KEY_BORDER_STYLE_DASHED:
                style = Annot.BorderStyle.e_dashed;
                break;
            case KEY_BORDER_STYLE_BEVELED:
                style = Annot.BorderStyle.e_beveled;
                break;
            case KEY_BORDER_STYLE_INSET:
                style = Annot.BorderStyle.e_inset;
                break;
            case KEY_BORDER_STYLE_UNDERLINE:
                style = Annot.BorderStyle.e_underline;
                break;
            default:
                return null;
        }

        int horizontalCornerRadius = (int) (object.getDouble(KEY_BORDER_STYLE_OBJECT_HORIZONTAL_CORNER_RADIUS) + 0.5);
        int verticalCornerRadius = (int) (object.getDouble(KEY_BORDER_STYLE_OBJECT_VERTICAL_CORNER_RADIUS) + 0.5);
        int width = (int) (object.getDouble(KEY_BORDER_STYLE_OBJECT_WIDTH) + 0.5);

        if (isJSONKeyValid(object, KEY_BORDER_STYLE_OBJECT_DASH_PATTERN)) {
            try {
                JSONArray dashPatternJSONArray = getJSONArrayFromJSONObject(object, KEY_BORDER_STYLE_OBJECT_DASH_PATTERN);
                double[] dashPattern = new double[dashPatternJSONArray.length()];

                for (int i = 0; i < dashPatternJSONArray.length(); i++) {
                    dashPattern[i] = dashPatternJSONArray.getDouble(i);
                }

                return new Annot.BorderStyle(style, width, horizontalCornerRadius, verticalCornerRadius, dashPattern);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return new Annot.BorderStyle(style, width, horizontalCornerRadius, verticalCornerRadius);
    }

    private static ColorPt getColorPtFromJSONObject(JSONObject object) throws PDFNetException, JSONException {
        if (!areJSONKeysValid(object, KEY_COLOR_RED, KEY_COLOR_GREEN, KEY_COLOR_BLUE)) {
            return null;
        }

        double red = object.getDouble(KEY_COLOR_RED);
        double green = object.getDouble(KEY_COLOR_GREEN);
        double blue = object.getDouble(KEY_COLOR_BLUE);

        return new ColorPt(red, green, blue);
    }

    public static JSONArray getJSONArrayFromJSONObject(JSONObject jsonObject, String key) throws JSONException {
        String jsonArrayString = jsonObject.getString(key);
        return new JSONArray(jsonArrayString);
    }

    public static JSONObject getJSONObjectFromJSONObject(JSONObject jsonObject, String key) throws JSONException {
        String jsonObjectString = jsonObject.getString(key);
        return new JSONObject(jsonObjectString);
    }

    public static ArrayList<String> convertJSONArrayToArrayList(JSONArray jsonArray) throws JSONException {
        ArrayList<String> arrayList = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            arrayList.add(jsonArray.getString(i));
        }
        return arrayList;
    }

    // this function returns true iff the key exists and does not have a null value associated with it
    public static boolean isJSONKeyValid(JSONObject jsonObject, String key) throws JSONException {
        return jsonObject.has(key) && !jsonObject.isNull(key) && !jsonObject.getString(key).equals("null");
    }

    public static boolean areJSONKeysValid(JSONObject jsonObject, String... keys) throws JSONException {
        for (String key : keys) {
            if (!isJSONKeyValid(jsonObject, key)) {
                return false;
            }
        }
        return true;
    }
}
