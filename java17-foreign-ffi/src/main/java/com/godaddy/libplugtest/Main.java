package com.godaddy.libplugtest;

public class Main {
    public static void main(String[] args) {
        System.out.println("Creating Libplugtest object");
        var libplugtest = new Libplugtest();
        try {
            System.out.println("Calling toUpper()");
            System.out.println(libplugtest.toUpper("Initial value"));
        } catch (Throwable t) {
            System.out.println(t);
        }

    }
}
