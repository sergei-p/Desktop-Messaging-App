import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

Page {
    id: root
    Rectangle{
        id: windowContainer
        width: 640
        height: 480
        color: "gray"
        // contains the input label
        Rectangle{
            id: inputLabelContainer
            x: 270
            y: 160
            height: 50
            width: 100
            color: "gray"

            Text{
                id: inputLabel
                anchors.centerIn: parent
                text: "Name"
                color: "black"
                font.family: "Montserrat"
                font.pointSize: 10.5
            }
        }
        //contains the user input
        Rectangle{
            id: userNameInputBox
            x: 120
            y: 215
            height: 50
            width: 270
            color: "white"

            TextInput{
                id: inputtedUserName
                color: "black"
                font.family: "Montserrat"
                font.pointSize: 10
                anchors.fill: parent
                clip: true
                selectByMouse: true
                padding: 4
            }
        }
        // This button is responsible for registrering the
        // the inputed username and opening the chatview page
        Button{
            id: submitButton
            x: 395
            y: 215
            height: 50
            width: 125
            onClicked: function() {
                // the user name must be greate than 0
                if(inputtedUserName.text.length > 0){
                    root.StackView.view.push("qrc:/ChatView.qml", {currentUser: inputtedUserName.text})
                }
            }
            Text{
                id: submitButtonLabel
                anchors.centerIn: parent
                text: "Submit"
                color: "black"
                font.family: "Montserrat"
                font.pointSize: 10.5
            }
        }


    }

}
