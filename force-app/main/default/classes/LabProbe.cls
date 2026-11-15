public with sharing class LabProbe {
    public static String greet(String name) {
        return address('Hi', name);
    }

    public static String farewell(String name) {
        return address('Bye', name);
    }

    private static String address(String salutation, String name) {
        String addressee = String.isBlank(name) ? 'lab' : name.trim();
        String message = salutation + ', ' + addressee;
        System.debug(LoggingLevel.INFO, 'LabProbe: ' + message);
        return message;
    }
}
