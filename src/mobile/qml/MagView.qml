/*********
*
* In the name of the Father, and of the Son, and of the Holy Spirit.
*
* This file is part of BibleTime's source code, http://www.bibletime.info/.
*
* Copyright 1999-2016 by the BibleTime developers.
* The BibleTime source code is licensed under the GNU General Public License
* version 2.0.
*
**********/

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import BibleTime 1.0

FocusScope {
    id: magView

    property int magViewMargins: btStyle.pixelsPerMillimeterX * 0.75

    signal magFinished();

    function initialize() {
        btWindowInterface.updateDefaultModules();
        if (btWindowInterface.moduleName == "") {
            console.log("MagView needs initialize")
            var moduleName = btWindowInterface.getDefaultSwordModuleByType("standardBible");
            if (moduleName != "") {
                btWindowInterface.moduleName = moduleName;
                console.log("MagView set to", moduleName);
            }
        }
    }

    function setModule(module) {
        btWindowInterface.moduleName = module;
        btWindowInterface2.moduleName = module;
    }

    function setReference(reference) {
        btWindowInterface.reference = reference;
    }

    function scrollDocumentViewToCurrentReference() {
        btWindowInterface.updateCurrentModelIndex();
    }

    function updateTextFont() {
        btWindowInterface.updateTextFonts();
        btWindowInterface2.updateTextFonts();
    }

    Keys.onReleased: {
        if ((event.key == Qt.Key_Back || event.key == Qt.Key_Escape) && magView.focus == true) {
            magFinished();
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: btStyle.textBackgroundColor
    }

    Text {
        id: pageTitle
        color: btStyle.toolbarTextColor
        font.pointSize: btStyle.uiFontPointSize * 1.1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: toolbar.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTranslate("MagView", "View References")
        z: 1
    }

    Rectangle {
        id: toolbar

        height: {
            var pixel = btStyle.pixelsPerMillimeterY * 7;
            var uiFont = btStyle.uiFontPointSize * 3;
            var mix = pixel * 0.7 + uiFont * 0.3;
            return Math.max(pixel, mix);
        }
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: height * 0.8
        color: btStyle.toolbarColor

        Rectangle {
            id: moduleDisplay

            width: text.width + 30
            radius:btStyle.pixelsPerMillimeterX
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: magView.magViewMargins
            anchors.topMargin: magView.magViewMargins
            anchors.bottomMargin: magView.magViewMargins
            color: btStyle.textBackgroundColor
            border.color: btStyle.toolbarTextColor
            border.width: 2

            Text {
                id: text

                anchors.centerIn: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                font.pointSize: btStyle.uiFontPointSize
                elide: Text.ElideMiddle
                color: btStyle.textColor
                text: btWindowInterface.moduleName
            }

            MouseArea {
                id: moduleMouseArea

                anchors.fill: parent
                onClicked: {
                    btWindowInterface.changeModule();
                }
            }
        }

        Rectangle {
            id: referenceDisplay

            anchors.left: moduleDisplay.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: magView.magViewMargins
            anchors.bottomMargin: magView.magViewMargins
            anchors.leftMargin:  magView.magViewMargins
            anchors.rightMargin: magView.magViewMargins
            border.color: btStyle.toolbarTextColor
            border.width: 2
            color: btStyle.textBackgroundColor
            radius: btStyle.pixelsPerMillimeterX

            Text {
                id: referenceText
                anchors.fill: parent
                anchors.leftMargin: btStyle.pixelsPerMillimeterX *4.5
                anchors.rightMargin: 4
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pointSize: btStyle.uiFontPointSize
                elide: Text.ElideMiddle
                color: btStyle.textColor
                text: btWindowInterface.reference
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                onClicked: {
                    btWindowInterface.changeReference();
                }
            }
        }

    }

    SplitView {
        id: splitView

        property real ratio: 0.5

        signal handleChanged()

        function setOrientation() {
            if (width > height) {
                splitView.orientation = Qt.Horizontal;
            } else {
                splitView.orientation = Qt.Vertical;
            }
        }

        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: magView.magViewMargins
        anchors.rightMargin: magView.magViewMargins
        anchors.topMargin: magView.magViewMargins
        anchors.bottomMargin: magView.magViewMargins

        handleDelegate: Rectangle {
            id: handle

            width: btStyle.pixelsPerMillimeterX * 1.6
            height: btStyle.pixelsPerMillimeterX * 1.6
            color: btStyle.textBackgroundColor
        }

        Component.onCompleted: {
            splitView.ratio = btmConfig.getReal("ui/MagViewRatio", 0.5);
            documentView.computeDocumentSize();
        }

        onHandleChanged: {
            splitView.ratio = (splitView.orientation == Qt.Horizontal) ?
                        documentView.width / width :
                        documentView.height / height;
            btmConfig.setReal("ui/MagViewRatio", splitView.ratio);
        }
        onWidthChanged: {
            setOrientation();
            documentView.computeDocumentSize();
        }
        onHeightChanged: {
            setOrientation();
            documentView.computeDocumentSize();
        }

        onVisibleChanged: {
            setOrientation();
            documentView.computeDocumentSize();
        }

        Rectangle {
            id: documentView

            function computeDocumentSize() {
                if (splitView.orientation == Qt.Horizontal) {
                    documentView.width = splitView.width * splitView.ratio;
                } else {
                    documentView.height = splitView.height * splitView.ratio;
                }
            }

            height: 100
            width: 100
            color: btStyle.textBackgroundColor
            border.width: 1
            border.color: btStyle.textColor
            radius: btStyle.pixelsPerMillimeterX

            onWidthChanged: {
                if ( (splitView.orientation == Qt.Horizontal) && splitView.resizing )
                    splitView.handleChanged()
            }
            onHeightChanged: {
                if ( (splitView.orientation == Qt.Vertical) && splitView.resizing )
                    splitView.handleChanged()
            }

            ListView {
                id: documentListView

                clip: true
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: promptText.top
                anchors.leftMargin: magView.magViewMargins
                anchors.rightMargin: magView.magViewMargins
                anchors.topMargin: magView.magViewMargins
                anchors.bottomMargin: magView.magViewMargins
                model: btWindowInterface.textModel
                highlightFollowsCurrentItem: true
                currentIndex: btWindowInterface.currentModelIndex
                onCurrentIndexChanged: {
                    positionViewAtIndex(currentIndex,ListView.Beginning)
                }
                onMovementEnded: {
                    var index = indexAt(contentX,contentY+30);
                    btWindowInterface.updateKeyText(index);
                }

                delegate: Text {
                    text: line
                    textFormat: Text.RichText
                    width: parent.width
                    color: btStyle.textColor
                    font.family: btWindowInterface.fontName
                    font.pointSize: btWindowInterface.fontSize
                    wrapMode: Text.WordWrap
                    onWidthChanged: doLayout()
                    onLinkActivated: {
                        btWindowInterface2.setReferenceByUrl(link);
                        btWindowInterface2.updateCurrentModelIndex();
                    }
                }
            }

            Text {
                id: promptText

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width * .95
                anchors.leftMargin: btStyle.pixelsPerMillimeterX
                anchors.bottomMargin: btStyle.pixelsPerMillimeterX
                font.pointSize: btStyle.uiFontPointSize
                color: btStyle.toolbarTextColor
                elide: Text.ElideMiddle
                text: btWindowInterface2.prompt

            }
        }

        Rectangle {
            id: referencesView

            property int refMargins: btStyle.pixelsPerMillimeterX * 2
            color: btStyle.textBackgroundColor
            Layout.fillWidth: (splitView.orientation == Qt.Horizontal) ? true : false
            Layout.fillHeight: (splitView.orientation == Qt.Vertical) ? true : false
            border.width: 1
            border.color: btStyle.textColor
            radius: btStyle.pixelsPerMillimeterX

            Text {
                id: referenceTitle

                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width * .95

                height: {
                    var pixel = btStyle.pixelsPerMillimeterY * 3.2;
                    var uiFont = btStyle.uiFontPointSize * 4.5;
                    var mix = pixel * 0.7 + uiFont * 0.3;
                    return Math.max(pixel, mix);
                }

                anchors.topMargin: btStyle.pixelsPerMillimeterX
                anchors.leftMargin: btStyle.pixelsPerMillimeterX
                anchors.rightMargin: btStyle.pixelsPerMillimeterX
                font.pointSize: btStyle.uiFontPointSize
                color: btStyle.toolbarTextColor
                elide: Text.ElideMiddle
                text: btWindowInterface2.referencesViewTitle
            }

            ScrollView {
                id: footnoteView

                anchors.top: referenceTitle.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: magView.magViewMargins
                anchors.rightMargin: magView.magViewMargins
                anchors.topMargin: magView.magViewMargins
                anchors.bottomMargin: magView.magViewMargins
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                visible: btWindowInterface2.footnoteVisible
                z: 1
                Text {
                    id: footnoteText

                    color: btStyle.textColor
                    font.family: btWindowInterface2.fontName
                    font.pointSize: btWindowInterface2.fontSize
                    text: btWindowInterface2.footnoteText
                    textFormat: Text.RichText
                    width: footnoteView.width
                    wrapMode: Text.WordWrap
                }
            }

            ListView {
                id: referencesListView

                anchors.top: referenceTitle.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                width: parent.width
                anchors.leftMargin: magView.magViewMargins
                anchors.rightMargin: magView.magViewMargins
                anchors.topMargin: magView.magViewMargins
                anchors.bottomMargin: magView.magViewMargins
                model: btWindowInterface2.textModel
                highlightFollowsCurrentItem: true
                currentIndex: btWindowInterface2.currentModelIndex
                visible: !btWindowInterface2.footnoteVisible

                onCurrentIndexChanged: {
                    positionViewAtIndex(currentIndex,ListView.Beginning)
                }

                delegate: Text {
                    text: line
                    textFormat: Text.RichText
                    width: parent.width
                    color: btStyle.textColor
                    font.family: btWindowInterface2.fontName
                    font.pointSize: btWindowInterface2.fontSize
                    wrapMode: Text.WordWrap
                    onWidthChanged: doLayout()
                }
            }
        }
    }

    BtStyle {
        id: btStyle
    }

    BtmConfig {
        id: btmConfig
    }

    BtWindowInterface {
        id: btWindowInterface

        isMagView: true
        onModuleChanged: {
            btWindowInterface2.moduleName = btWindowInterface.moduleName
        }
    }

    BtWindowInterface {
        id: btWindowInterface2

        onReferenceChange: {
            btWindowInterface2.updateCurrentModelIndex();
        }
    }

}