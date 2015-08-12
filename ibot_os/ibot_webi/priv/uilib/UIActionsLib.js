/**
 * Created by alex on 8/10/15.
 */


function ReceivedMessage(jsonMessage) {
    var response = JSON.parse(jsonMessage);

    this.messageType = response['message_type'];
    this.nodeName = response['node_name'];
    this.messageClassName = response['message_class_name'];
    this.additionalInfo = response['additional_info'];
    this.message = response['message'];
}

function sendDataToTopic(Msg)
{
    var jsonQ = "{\"sendData\" : {\"sendType\" : \""+ "broadcast" +
        "\", \"topicName\" : \"" + "testTopic" + "\", \"message\" : " + Msg.getMessage() + "}}";
    ws.send(jsonQ);
    console.log(jsonQ);
}