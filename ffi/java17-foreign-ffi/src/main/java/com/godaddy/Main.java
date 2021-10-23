package com.godaddy;

public class Main {
    public static void main(String[] args) {
        System.out.println("Creating CobhanDemoLib object");
        var cobhandemolib = new CobhanDemoLib();
        try {
            System.out.println("Calling toUpper()");
            System.out.println(cobhandemolib.toUpper("Initial value"));
        } catch (Throwable t) {
            System.out.println(t);
        }

    }
}
