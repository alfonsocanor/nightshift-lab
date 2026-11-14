@IsTest
private class LabProbeTest {
    @IsTest
    static void greetsByName() {
        Assert.areEqual('Hello, Nightshift', LabProbe.greet('Nightshift'));
    }

    @IsTest
    static void greetsTheLabWhenNoNameIsGiven() {
        Assert.areEqual('Hello, lab', LabProbe.greet(''));
    }
}
