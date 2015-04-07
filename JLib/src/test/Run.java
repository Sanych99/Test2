package test;

import java.lang.reflect.InvocationTargetException;

/**
 * Created by alex on 27.03.2015.
 */
public class Run extends ParentClass {

    public Integer var1 = 100;

    public void printVar()
    {
        System.out.print(var1.toString());
    }


    public Run(){
        super();
        System.out.println("Run");
    }



    public static void main(String [] args) throws InvocationTargetException, NoSuchMethodException, InstantiationException, IllegalAccessException {
        //ChildClass childClass = new ChildClass();
        //childClass.test();
        //childClass.var1 = 999;
        //childClass.test();

        Run run = new Run();

        for(Integer i=0; i<200; i++)
            System.out.println("in main " + i.toString());

    }
}
