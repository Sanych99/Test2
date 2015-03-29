package test;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Created by alex on 27.03.2015.
 */
public class ParentClass {

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
