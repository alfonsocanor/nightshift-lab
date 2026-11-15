public with sharing class ContactTriggerHandler {
    private static final String NIGHTSHIFT = 'Nightshift';
    private static final String SUFFIX = ' ' + NIGHTSHIFT;
    private static final Integer LAST_NAME_LENGTH =
        Contact.LastName.getDescribe().getLength();

    public static void beforeInsert(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (takesNightshift(contact.LastName)) {
                contact.LastName += SUFFIX;
            }
        }
    }

    private static Boolean takesNightshift(String lastName) {
        return String.isNotBlank(lastName) &&
            !alreadyEndsInNightshift(lastName) &&
            hasRoomForNightshift(lastName);
    }

    private static Boolean alreadyEndsInNightshift(String lastName) {
        return lastName.equalsIgnoreCase(NIGHTSHIFT) ||
            lastName.endsWithIgnoreCase(SUFFIX);
    }

    private static Boolean hasRoomForNightshift(String lastName) {
        return lastName.length() + SUFFIX.length() <= LAST_NAME_LENGTH;
    }
}
