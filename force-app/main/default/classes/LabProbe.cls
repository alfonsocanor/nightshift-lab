public with sharing class LabProbe {
    public static String greet(String name) {
        String greeting = 'Hello, ' + (String.isBlank(name) ? 'lab' : name);
        System.debug(LoggingLevel.INFO, greeting);
        return greeting;
    }
}
