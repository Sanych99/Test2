package langlib.java;

import jdk.nashorn.internal.codegen.CompilerConstants;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Objects;

/**
 * Created by alex on 3/12/15.
 */
public class CallBack {
    private String methodName;
    //private Class<?> scope;

    //public CallBack(Class<?> scope) {
        //this.methodName = methodName;
        //this.scope = scope;
    //}

    public void set_methodName(String methodName)
    {
        this.methodName = methodName;
    }

    //public Class<?> get_scope()
    //{
    //    return this.scope;
    //}

    //public Object invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    //    Method method = scope.getMethod(methodName, getParameterClasses(parameters));
    //    return method.invoke(scope, parameters);
    //}

    public void invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        Method method = this.getClass().getMethod(methodName, getParameterClasses(parameters));
        method.invoke(this, parameters);
    }

    private Class[] getParameterClasses(Object... parameters) {
        Class[] classes = new Class[parameters.length];
        for (int i=0; i < classes.length; i++) {
            classes[i] = parameters[i].getClass();
        }
        return classes;
    }
}