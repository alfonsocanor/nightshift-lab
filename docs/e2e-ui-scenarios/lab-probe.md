# LabProbe: scenarios

`LabProbe` (`force-app/main/default/classes/LabProbe.cls`) greets and says goodbye: `greet(name)` returns `Hi, <name>` and `farewell(name)` returns `Bye, <name>`. Both trim the name, and both say `lab` when the name is blank. Nothing shows on a page, so every check here runs without a browser.

## Data

None. `LabProbe` reads and writes no records, and its result is the same whoever runs it.

## Runbook

- Org: `lab-dev`.
- Deploy both classes and run their tests:
  `sf project deploy start --source-dir force-app/main/default/classes/LabProbe.cls --source-dir force-app/main/default/classes/LabProbeTest.cls --test-level RunSpecifiedTests --tests LabProbeTest --ignore-conflicts --target-org lab-dev`
- LP-01: `sf apex run test --class-names LabProbeTest --code-coverage --synchronous --target-org lab-dev`
- LP-02: the probe `LabProbeFarewellProbe`, run as a check-only deploy with `RunSpecifiedTests` so nothing stays in the org.

## Scenarios

| Id | Name | Description | Who | Steps | Expected |
| --- | --- | --- | --- | --- | --- |
| LP-01 | LabProbeTest passes | Every LabProbeTest test passes and covers LabProbe in full, for greet and farewell alike. | Nightshift (Apex test run) | 1. Deploy `LabProbe` and `LabProbeTest` to `lab-dev`. 2. Run `LabProbeTest` with code coverage. | 6 tests run, 6 pass: `greetsByName`, `greetsTheLabWhenNoNameIsGiven`, `trimsTheNameItIsGiven`, `saysByeByName`, `saysByeToTheLabWhenNoNameIsGiven`, `trimsTheNameItSaysByeTo`. `LabProbe` coverage is 100%. |
| LP-02 | Farewell edge cases | Names the tests leave out (null, spaces only) get the lab, and greet still trims. | Apex probe as the running user | 1. Call `LabProbe.farewell(null)`. 2. Call `LabProbe.farewell('   ')`. 3. Call `LabProbe.greet('  Nightshift  ')`. | 1. `Bye, lab`. 2. `Bye, lab`. 3. `Hi, Nightshift`. |

## Results

### 2026-11-15, Nightshift task 20261115-jtnty, Apex tests and a check-only probe in lab-dev

| Id | Result | Seen | Code | Records |
| --- | --- | --- | --- | --- |
| LP-01 | Pass | Deploy 0Afhv0000017K4fCAE succeeded. `sf apex run test`: outcome Passed, 6 ran, 6 passing, 0 failing, `LabProbe` 100% covered (8 of 8 lines). | force-app/main/default/classes/LabProbe.cls:4, force-app/main/default/classes/LabProbe.cls:9, force-app/main/default/classes/LabProbe.cls:14, force-app/main/default/classes/LabProbeTest.cls:21, force-app/main/default/classes/LabProbeTest.cls:26, force-app/main/default/classes/LabProbeTest.cls:31 | 01phv000005ZVZ7AAO, 01phv000005ZVZ8AAO |
| LP-02 | Pass | Check-only deploy 0Afhv0000017K7tCAE: `edgeCasesAddressTheLabAndGreetStillTrims` passed, 1 run, 0 failures. `farewell(null)` and `farewell('   ')` returned `Bye, lab`, and `greet('  Nightshift  ')` returned `Hi, Nightshift`. | force-app/main/default/classes/LabProbe.cls:4, force-app/main/default/classes/LabProbe.cls:9, force-app/main/default/classes/LabProbe.cls:14 | 01phv000005ZVZ7AAO |
