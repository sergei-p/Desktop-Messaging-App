import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import QtWebSockets 1.1

Page{
    id: root
    property string currentUser         // holds the name of the current user of the client
    property int numUsersConnected: 0   // holds the number of currently connected users to this client
    property string prvtMsgRecipient: "NULL" // pirvate message recipient ( used of the extra credit portion)


    WebSocket{
        id:socket
        active: true
        url: "ws://localhost:8080"
        onTextMessageReceived: function(message){
            console.log("Recieved:", message)

            // check if data recieved is a JSON object
            if(isJSON(message) === false){

                socket.sendTextMessage(currentUser + " received (" + message + ")")
            } else{
                // Each recieved JSON object has unique dataType identifier,
                // which defines the type of operation that needs to be
                // done with the data
                if(JSON.parse(message).dataType === "message"){
                    //add message to message board
                    addMessageToBoard(message)

                } else if(JSON.parse(message).dataType === "makeConnections"){
                    // for new connection, add all users to users board
                    addAllUsers(JSON.parse(message).connectedUsers)

                } else if(JSON.parse(message).dataType === "addUsr"){
                    // when new user, connect that user to users' board
                    addUser(JSON.parse(message).name)

                } else if(JSON.parse(message).dataType === "usrDisconnect"){
                    // remove disconnected user from users' board
                    removeUser(JSON.parse(message).name)

                } else{
                    // if none of the previous operations occured, an
                    // error most likely occured
                    chatTranscriptText.append("An Error Has Occured")
                }
            }
        }
    }

    // Returns true if the passed in value is a JSON object
    // https://stackoverflow.com/questions/3710204/how-to-check-if-a-string-is-a-valid-json-string-in-javascript-without-using-try
    function isJSON (theObj) {
        if (typeof theObj != 'string')
            theObj = JSON.stringify(theObj);

        try {
            JSON.parse(theObj);
            return true;
        } catch (e) {
            return false;
        }
    }

    // Adds message and name of user who sent the message
    // to the message board
    function addMessageToBoard(message){

        var sendUsr = JSON.parse(message).name
        var recievedMsg = JSON.parse(message).message

        var displayString
        if(sendUsr === currentUser){
            displayString = "(Me): " + recievedMsg
        } else {
            displayString = "<b>" + sendUsr + "</b>" + ": " + recievedMsg
        }

        chatTranscriptText.append(displayString)
    }

    // Adds one user to the display board
    function addUser(user){
        if(user !== currentUser){
            connectedUsrsListModel.append({displayedUser: user})
//            console.log(user)
        }
        numUsersConnected++
    }


    // Adds a list of user to the display board
    function addAllUsers(userList){
        // get number of items in userList object
        var userListLength = countProperties(userList)

        for(var i = 0; i < userListLength; i++){
            if(userList[i] !== currentUser){
                if(userList[i] !== undefined){
                    connectedUsrsListModel.append({displayedUser: userList[i]})
                    numUsersConnected++
                }
            }
        }
    }

    // Removes a user from the display board
    function removeUser(user){
        for(var i = 0; i < numUsersConnected; i++){
            if(user === prvtMsgRecipient){
                prvtMsgRecipient = "NULL"
            }

            if(user === connectedUsrsListModel.get(i).displayedUser){
                connectedUsrsListModel.remove(i)
                numUsersConnected--
            }
        }
    }

    // Returns the number of items in an object
    //https://stackoverflow.com/questions/956719/number-of-elements-in-a-javascript-object
    function countProperties(obj) {
        return Object.keys(obj).length;
    }


    // This rectangle holds the users label
    Rectangle{
        id: usersLabel
        x: 0
        y: 0
        width: 192
        height: 25
        color: "#290A4E"

        Text {
            text: "Users"
            anchors.centerIn: parent
            font.family: "Montserrat"
            font.pointSize: 10.5
            color: "white"
            }
        }

    // This rectangle displays the currently connected users
    Rectangle{
        id: userDisplayBoard
        x: 0
        y: 25
        width: 192
        height: 455
        color: "#290A4E"

    // this segment is responsible for displaying the
    // currently connected users
    ListView{
        id: connectedUsrsListView
        anchors.fill: parent
        model: connectedUsrsListModel
        delegate: Button{
                    x: 0
                    y: 0
                    width: 192
                    height: 25
                    scale: pressed ? 1.1 : 1
                    // The following method is responsible for assigning
                    // the current private message recipient based, on the user button
                    // that was selected. Also this methods displays a message in the
                    // message board, notifying that a private message session has started
                    // and ended.
                    onClicked: function(){
                        if(prvtMsgRecipient === "NULL"){
                            chatTranscriptText.append("Only " + displayedUser + " will see your messages now.")
                            prvtMsgRecipient = displayedUser
                        } else if(prvtMsgRecipient === displayedUser){
                            chatTranscriptText.append("Private message session with " + displayedUser + " has ended, you are back in general chat.")
                            prvtMsgRecipient = "NULL"
                        } else{
                            chatTranscriptText.append("Private message session with " + prvtMsgRecipient + " has ended")
                            chatTranscriptText.append("Only " + displayedUser + " will see your messages now")
                            prvtMsgRecipient = displayedUser
                        }
                    }

                    Behavior on scale { NumberAnimation { duration: 100 } }
                    background: Rectangle{
                        color: "#4D6DDB"
                    }
                    Text{
                        text: displayedUser
                        padding: 4
                        color: "black"
                        font.family: "Montserrat"
                        font.pointSize: 10.5
                    }
                }
            }
        // this list model holds the currently connected users
        ListModel{
            id: connectedUsrsListModel
        }
    }

    // This rectangle holds the Conversation label
    Rectangle{
        id: conversationLabel
        x: 192
        y: 0
        width: 448
        height: 50
        color: "white"
        Text{
            text: "Conversation"
            anchors.centerIn: parent
            font.family: "Montserrat"
            font.pointSize: 10.5
            color: "Black"
            }
    }

    // This rectangle contains the conversation
    Rectangle{
        id: messageLog
        x: 197
        y: 50
        width: 438
        height: 350
        border.color: "black"
        border.width: 2
        radius: 5

        // This component provides a scrolling capability for the message board
        ScrollView{
            id: chatTranscirptScroll
            x: 5
            y: 5
            width: 428
            height: 340
            clip: true
            // This segement is responsible for displaying the conversation
            TextEdit{
                id: chatTranscriptText
                width: 428
                height: chatTranscirptScroll.height
                readOnly: true
                textFormat: Text.RichText //enables HTML formatting
                wrapMode: TextEdit.Wrap
                font.family: "Montserrat"
                font.pointSize: 10.5
            }
        }
    }

        // This rectangle contains the message input box
    Rectangle{
        id: textInputBox
        x: 5 + 192
        y: 405 // 390 + 5(margin)
        width: 338
        height: 70
        border.color: "black"
        border.width: 2
        radius: 5

        // Check if the message, which was inputted into the 'text input box'
        // is a private message or not. if yes, then a private message recipient
        // is added to the prvtMsgRecipient field, other wise the message
        // is marked to be recieved by all
        function sendData(){
            if(textInput.text.length > 0){
                var userName
                var myData
                if(prvtMsgRecipient !== "NULL"){
                    userName = currentUser
                    myData = {
                        dataType: "message",
                        name: userName,
                        message: textInput.text + " (private)",
                        UUID: "NULL",
                        connectedUsers: {},
                        prvtMsgRecipient: prvtMsgRecipient
                        };
                 } else{
                    userName = currentUser
                    myData = {
                        dataType: "message",
                        name: userName,
                        message: textInput.text,
                        UUID: "NULL",
                        connectedUsers: {},
                        prvtMsgRecipient: "NULL"
                        };
                 }
                //var theData = JSON.stringify(myData)
                socket.sendTextMessage(JSON.stringify(myData))
                textInput.clear()

            }
        }

        // This model provides the capablity for inputting text
        TextInput{
            id: textInput
            color: "black"
            font.family: "Montserrat"
            font.pointSize: 10
            wrapMode: Text.WrapAnywhere
            anchors.fill: parent
            clip: true
            selectByMouse: true
            padding: 4
        }

    }

    // This button is responsible for activating the the sendData() method
    Button{
        id: sendButton
        x: 540
        y: 405
        width: 95
        height: 70
        onClicked: textInputBox.sendData()  // if have time add validation, to check if server is running or compatible

        Text{
            id: buttonLabel
            anchors.centerIn: parent
            text: "Send"
            color: "black"
            font.family: "Montserrat"
            font.pointSize: 10.5
        }
    }

}


