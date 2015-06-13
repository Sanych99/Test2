import langlib.java.*;

public class PubsubServer extends BotNode {

	public void CallBackMethod(TestMsg msg) {
		System.out.println("Get message: " + msg.get_strParam());
	}

	public PubsubServer(String[] args) throws Exception {
		//super(args);
		super(new String[] {"PubsubServer", "127.0.0.1", "core@127.0.0.1", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"});
	}


	public void Action() throws Exception {
		this.subscribeToTopic("testTopic", "CallBackMethod", TestMsg.class);

		System.out.println("READY!");
	}

	public static void main (String[] args) throws Exception {
		PubsubServer pubsubserver = new PubsubServer(args);
		pubsubserver.Action();
	    }

}
