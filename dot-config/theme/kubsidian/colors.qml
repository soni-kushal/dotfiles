pragma Singleton

import QtQuick

QtObject {

    // ==============================
    // BACKGROUNDS
    // ==============================

    readonly property color void: "#09090C"
    readonly property color base: "#101119"
    readonly property color surface: "#161722"
    readonly property color elevated: "#9292A8"


    // ==============================
    // BORDERS
    // ==============================

    readonly property color borderActive: "#F2F2F0"
    readonly property color borderInactive: "#3A404A"


    // ==============================
    // TYPOGRAPHY
    // ==============================

    readonly property color textPrimary: "#F2F2F0"
    readonly property color textSecondary: "#C4C7CC"
    readonly property color textMuted: "#858B95"
    readonly property color textDisabled: "#515660"


    // ==============================
    // ACCENTS
    // ==============================

    readonly property color steelBlue: "#829DBB"
    readonly property color violet: "#A092B5"
    readonly property color rose: "#B98D99"
    readonly property color olive: "#A1A184"
    readonly property color copper: "#B68E73"
    readonly property color teal: "#7FA6A2"


    // ==============================
    // SEMANTIC
    // ==============================

    readonly property color error: "#D4777D"
    readonly property color success: "#91B89B"
    readonly property color warning: "#D4AD72"
    readonly property color info: "#82A8D0"
}
