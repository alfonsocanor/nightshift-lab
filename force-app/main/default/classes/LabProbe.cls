public with sharing class LabProbe {
    public static String greet(String name) {
        String greeting = 'Hi, ' + (String.isBlank(name) ? 'lab' : name.trim());
        System.debug(LoggingLevel.INFO, 'LabProbe: ' + greeting);
        return greeting;
    }
}
