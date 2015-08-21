package ibot.mongotest;

import com.mongodb.*;
import langlib.java.BotNode;

import java.util.Date;

/**
 * Created by alex on 8/22/15.
 */
public class MongoTest extends BotNode {

    public MongoTest(String[] args) throws Exception {
        super(args);
    }

    @Override
    public void Action() throws Exception {
        MongoClient mongo = new MongoClient( "localhost" , 27017 );
        DB db = mongo.getDB("testdb");
        DBCollection table = db.getCollection("user");
        BasicDBObject document = new BasicDBObject();
        document.put("name", "mkyong");
        document.put("age", 30);
        document.put("createdDate", new Date());
        table.insert(document);



        DBCollection table2 = db.getCollection("user");

        BasicDBObject searchQuery = new BasicDBObject();
        searchQuery.put("name", "mkyong");

        DBCursor cursor = table2.find(searchQuery);

        while (cursor.hasNext()) {
            System.out.println(cursor.next());
        }
    }

    public static void main( String[] args ) throws Exception {
        System.out.println( "Hello World from maven project MongoTest!" );
        MongoTest app = new MongoTest(args);
        app.Action();
    }
}
