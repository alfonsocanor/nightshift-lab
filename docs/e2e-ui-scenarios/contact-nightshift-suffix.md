# Contact Nightshift suffix: scenarios

`ContactTrigger` (`force-app/main/default/triggers/ContactTrigger.trigger`) runs before a Contact is inserted and hands the records to `ContactTriggerHandler` (`force-app/main/default/classes/ContactTriggerHandler.cls`), which appends ` Nightshift` to each last name: `Qwerty Oiuy` is saved as `Qwerty Oiuy Nightshift`. The handler leaves a last name as it is when it is blank (Salesforce's required-field error still fires), when it already ends in the word `Nightshift` (any case), or when it is over 69 characters (`LastName` holds 80, so the suffix would not fit). Updates never add it. Nothing on a page changes, and the trigger runs the same for the record page, the API and Apex, so every check here runs without a browser.

## Data

- CN-01 and CN-02 create their contacts (and CN-02 its Standard User) inside Apex tests, which roll back: nothing stays in the org.
- CN-03 creates one contact, `Qwerty Oiuy`, through the API, reads it back, then deletes it.

## Runbook

- Org: `lab-dev`.
- Deploy the trigger, the handler and its test, and run the tests:
  `sf project deploy start --source-dir force-app/main/default/triggers/ContactTrigger.trigger --source-dir force-app/main/default/classes/ContactTriggerHandler.cls --source-dir force-app/main/default/classes/ContactTriggerHandlerTest.cls --test-level RunSpecifiedTests --tests ContactTriggerHandlerTest --ignore-conflicts --target-org lab-dev`
- CN-01: `sf apex run test --class-names ContactTriggerHandlerTest --code-coverage --synchronous --target-org lab-dev`
- CN-02: the probe `ContactNightshiftSuffixProbe`, run as a check-only deploy with `RunSpecifiedTests` so nothing stays in the org.
- CN-03:
  1. `sf data create record --sobject Contact --values "FirstName=Qwerty LastName=Oiuy" --target-org lab-dev`
  2. `sf data query --query "SELECT Id, LastName, Name FROM Contact WHERE Id = '<Id from step 1>'" --target-org lab-dev`
  3. `sf data delete record --sobject Contact --record-id <Id from step 1> --target-org lab-dev`

## Scenarios

| Id | Name | Description | Who | Steps | Expected |
| --- | --- | --- | --- | --- | --- |
| CN-01 | ContactTriggerHandlerTest passes | Every rule of the suffix holds on insert, in bulk and on update, and the trigger and handler are fully covered. | Nightshift (Apex test run) | 1. Deploy `ContactTrigger`, `ContactTriggerHandler` and `ContactTriggerHandlerTest` to `lab-dev`. 2. Run `ContactTriggerHandlerTest` with code coverage. | 7 tests run, 7 pass: `appendsNightshiftToTheLastName`, `appendsNightshiftToEveryContactInABulkInsert`, `leavesALastNameThatAlreadyEndsInNightshift`, `appendsNightshiftWhenItJustFits`, `leavesALastNameTooLongForTheSuffix`, `doesNotAppendAgainWhenTheLastNameIsUpdated`, `keepsTheRequiredFieldErrorWhenTheLastNameIsMissing`. `ContactTrigger` and `ContactTriggerHandler` coverage is 100%. |
| CN-02 | Standard User gets suffix | A Standard User who creates a contact gets the suffix, so it does not depend on an admin's access. | Apex probe as a Standard User (made in the probe) | 1. As the Standard User, insert a Contact with FirstName `Qwerty`, LastName `Oiuy`. 2. As that user, read its `Name`. | `Name` is `Qwerty Oiuy Nightshift`. |
| CN-03 | API insert gets suffix | A contact created through the API in the org is saved with the suffix, the owner's example. | Nightshift (sf CLI, org admin) | 1. Create a Contact `Qwerty Oiuy`. 2. Query its `LastName` and `Name`. 3. Delete it. | `LastName` is `Oiuy Nightshift`, `Name` is `Qwerty Oiuy Nightshift`; the delete succeeds. |

## Results

### 2026-11-15, Nightshift task 20261115-ytdn6, Apex tests, a check-only probe and an API insert in lab-dev

| Id | Result | Seen | Code | Records |
| --- | --- | --- | --- | --- |
| CN-01 | Pass | Deploy 0Afhv0000017a7pCAA succeeded with 7 tests, 0 errors. `sf apex run test`: outcome Passed, 7 ran, 7 passing, 0 failing; `ContactTriggerHandler` 100% (16 of 16 lines), `ContactTrigger` 100% (1 of 1). | force-app/main/default/triggers/ContactTrigger.trigger:3, force-app/main/default/classes/ContactTriggerHandler.cls:11, force-app/main/default/classes/ContactTriggerHandler.cls:17 | 01qhv000000tcHZAAY, 01phv000005bQYgAAM, 01phv000005bQYhAAM |
| CN-02 | Pass | Check-only deploy 0Afhv0000017a6DCAQ: `standardUserGetsNightshiftOnANewContact` passed, 1 run, 0 failures; the Standard User's new contact read back as `Qwerty Oiuy Nightshift`. | force-app/main/default/triggers/ContactTrigger.trigger:3, force-app/main/default/classes/ContactTriggerHandler.cls:11 | 01qhv000000tcHZAAY, 01phv000005bQYgAAM |
| CN-03 | Pass | Created 003hv000004WFflAAG with FirstName `Qwerty`, LastName `Oiuy`; the query returned LastName `Oiuy Nightshift`, Name `Qwerty Oiuy Nightshift`. The delete succeeded, so the contact is in the Recycle Bin. | force-app/main/default/triggers/ContactTrigger.trigger:3, force-app/main/default/classes/ContactTriggerHandler.cls:11 | 003hv000004WFflAAG |
