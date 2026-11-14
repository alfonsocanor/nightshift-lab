@IsTest
private class LabProbeTest {
    @IsTest
    static void greetsByName() {
        Assert.areEqual('Hi, Nightshift', LabProbe.greet('Nightshift'));
    }

    @IsTest
    static void greetsTheLabWhenNoNameIsGiven() {
        Assert.areEqual('Hi, lab', LabProbe.greet(''));
    }
}
