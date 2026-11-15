public with sharing class LabProbe {
    public static String greet(String name) {
        // ns:scn LP-01, LP-02
        return address('Hi', name);
    }

    // ns:scn LP-01, LP-02
    public static String farewell(String name) {
        return address('Bye', name);
    }

    // ns:scn LP-01, LP-02
    private static String address(String salutation, String name) {
        String addressee = String.isBlank(name) ? 'lab' : name.trim();
        String message = salutation + ', ' + addressee;
        System.debug(LoggingLevel.INFO, 'LabProbe: ' + message);
        return message;
    }
}
