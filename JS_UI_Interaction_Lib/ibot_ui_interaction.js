var ws = new Object;

/*Open websocket connection to iBotOS core*/
function open()
{
    if (!("WebSocket" in window)) {
        alert("WebSocket NOT supported by your Browser!");
        return;
    }
    console.log('open');
    ws = new WebSocket("ws://"+window.location.host+"/websocket");
    ws.onopen = function() {
        console.log('connected');
    };
    ws.onmessage = function (evt)
    {
        var received_msg = evt.data;
        console.log("Received: " + received_msg);

        var txt = document.createTextNode("Got from server: " + received_msg);
        document.getElementById('messages').appendChild(txt);

        var response = JSON.parse(received_msg);

        switch (response['responseType'])
        {
            case "nodeslist" :
                var nodesList = response['responseJson'].split("|");
                var nodeListHtml = "";
                for(var i=0; i<nodesList.length; i++)
                    nodeListHtml += generateNodeItem(nodesList[i]);
                $('#nodeListDiv').html(nodeListHtml);
                break;
        }
    };
    ws.onclose = function()
    {
        // websocket is closed.
        console.log('close');
    };
}



function sendMessage(msg) {
    ws.send(msg);
    console.log(msg);
}