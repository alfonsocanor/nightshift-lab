@IsTest
private class ContactTriggerHandlerTest {
    @IsTest
    static void appendsNightshiftToTheLastName() {
        Contact contact = new Contact(FirstName = 'Qwerty', LastName = 'Oiuy');
        insert contact;

        Contact saved = [
            SELECT LastName, Name FROM Contact WHERE Id = :contact.Id
        ];
        Assert.areEqual('Oiuy Nightshift', saved.LastName);
        Assert.areEqual('Qwerty Oiuy Nightshift', saved.Name);
    }

    @IsTest
    static void appendsNightshiftToEveryContactInABulkInsert() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(LastName = 'Oiuy ' + i));
        }
        insert contacts;

        Assert.areEqual(
            200,
            [
                SELECT COUNT()
                FROM Contact
                WHERE LastName LIKE 'Oiuy % Nightshift'
            ]
        );
    }

    @IsTest
    static void leavesALastNameThatAlreadyEndsInNightshift() {
        Contact contact = new Contact(LastName = 'Oiuy NIGHTSHIFT');
        insert contact;

        Assert.areEqual('Oiuy NIGHTSHIFT', lastNameOf(contact));
    }

    @IsTest
    static void appendsNightshiftWhenItJustFits() {
        String lastName = 'O'.repeat(69);
        Contact contact = new Contact(LastName = lastName);
        insert contact;

        Assert.areEqual(lastName + ' Nightshift', lastNameOf(contact));
    }

    @IsTest
    static void leavesALastNameTooLongForTheSuffix() {
        String lastName = 'O'.repeat(70);
        Contact contact = new Contact(LastName = lastName);
        insert contact;

        Assert.areEqual(lastName, lastNameOf(contact));
    }

    @IsTest
    static void doesNotAppendAgainWhenTheLastNameIsUpdated() {
        Contact contact = new Contact(LastName = 'Oiuy');
        insert contact;

        contact.LastName = 'Asdf';
        update contact;

        Assert.areEqual('Asdf', lastNameOf(contact));
    }

    @IsTest
    static void keepsTheRequiredFieldErrorWhenTheLastNameIsMissing() {
        try {
            insert new Contact(FirstName = 'Qwerty');
            Assert.fail('A contact with no last name was saved');
        } catch (DmlException e) {
            Assert.areEqual(StatusCode.REQUIRED_FIELD_MISSING, e.getDmlType(0));
        }
    }

    private static String lastNameOf(Contact contact) {
        return [SELECT LastName FROM Contact WHERE Id = :contact.Id].LastName;
    }
}
