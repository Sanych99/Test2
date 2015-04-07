package test;

import java.lang.reflect.InvocationTargetException;

/**
 * Created by alex on 27.03.2015.
 */
public class ChildClass extends ParentClass {
    public Integer var1 = 100;

    public void printVar()
    {
        System.out.print(var1.toString());
    }

    public ChildClass(){
        super();
        System.out.println("ChildClass");
    }

    public static void main(String [] args) throws InvocationTargetException, NoSuchMethodException, InstantiationException, IllegalAccessException {
        ChildClass childClass = new ChildClass();
        childClass.test();
        childClass.var1 = 999;
        childClass.test();

        String h = "hello!";

        switch (h)
        {
            case "hello!" : System.out.println("This is hello!");
        }

        for(Integer i=0; i<2000; i++)
            System.out.println("in main " + i.toString());
    }
}
