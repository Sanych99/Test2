/**
 * Created by alex on 8/15/15.
 */

var ws = new Object;

/*Open websocket connection to iBotOS core*/
function open(hostName)
{
    /*Проверка поддержки браузеров использования WebSocket*/
    if (!("WebSocket" in window)) {
        alert("WebSocket NOT supported by your Browser!");
        return;
    }

    /*Соединение с ядром*/
    console.log('open');
    ws = new WebSocket("ws://"+ hostName +"/websocket");

    /*Соединение прошло успешно*/
    ws.onopen = function() {
        console.log('connected');
    };

    /*Получено сообщение*/
    ws.onmessage = function (evt)
    {
        var received_msg = evt.data; /*Данные сообщения*/
        console.log("Received: " + received_msg);

        var response = JSON.parse(received_msg); /*Парси сообщение*/

        switch (response['message_type'])
        {
            /*Сообщение получено от узла*/
            case "send_data_to_ui" :
                var cratedMessage; /*Объект сообщения от узла*/
                var rMessage = new ReceivedMessage(received_msg); /*Парсим сообщение*/
                var cratedMessage = new window[rMessage.messageClassName](rMessage.message);
                var actionClass = new window[rMessage.messageClassName + '_logic'](cratedMessage);
                actionClass.action();
                break;
        }
    };

    ws.onclose = function()
    {
        // websocket is closed.
        console.log('close');
    };
}


/**
 * Парсим принятое сообщение для message_type = send_data_to_ui
 * @param jsonMessage
 * @constructor
 */
function ReceivedMessage(jsonMessage) {
    var response = JSON.parse(jsonMessage);

    this.messageType = response['message_type']; /*Тип сообщения*/
    this.nodeName = response['node_name']; /*Имя узла отправившего сообщение*/
    this.messageClassName = response['message_class_name']; /*Имя класса для принятия сообщения*/
    this.additionalInfo = response['additional_info']; /*Дополнительная информация (строка)*/
    this.message = response['message']; /*Сообщение (массив значений)*/
}


/**
 * Отправляем сообщение подписчикам топика
 * @param TopicName
 * @param Msg
 */
function sendDataToTopic(TopicName, Msg)
{
    var jsonQ = "{\"sendData\" : {\"sendType\" : \""+ "broadcast" +
        "\", \"topicName\" : \"" + TopicName + "\", \"message\" : " + Msg.getMessage() + "}}";
    ws.send(jsonQ);
    console.log(jsonQ);
}