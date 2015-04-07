package test;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Dictionary;
import java.util.Hashtable;

/**
 * Created by alex on 27.03.2015.
 */
public class ParentClass {

    private Dictionary<String, String> subscribeDic;

    public ParentClass()
    {
        subscribeDic = new Hashtable<String, String>();
        subscribeDic.put("1", "1");
        t.start();
    }



    Thread t = new Thread(new Runnable() {
        public void run()
        {
            for(Integer i=0; i<2000; i++)
                System.out.println("in thread " + i.toString());

            System.out.println(subscribeDic.get("1"));
            try {
                test();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
    });

    public void invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        Method method = this.getClass().getMethod("printVar", getParameterClasses(parameters));
        method.invoke(this, parameters);
    }

    private Class[] getParameterClasses(Object... parameters) {
        Class[] classes = new Class[parameters.length];
        for (int i=0; i < classes.length; i++) {
            classes[i] = parameters[i].getClass();
        }
        return classes;
    }

    public void test() throws NoSuchMethodException, InstantiationException, IllegalAccessException, InvocationTargetException {
        invoke();
    }
}
