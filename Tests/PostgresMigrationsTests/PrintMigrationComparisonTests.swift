#if compiler(>=6.2)
import Logging
import Testing

@testable import PostgresMigrations

@Suite("printMigrationComparison")
struct PrintMigrationComparisonTests {

    @Test("does not trap when later rows are longer than the first expected entry")
    func longerLaterRows() async {
        await #expect(processExitsWith: .success) {
            let logger = Logger(label: "postgres-migrations.test.print")
            let migrations = DatabaseMigrations()
            migrations.printMigrationComparison(
                expected: ["A", "ShorterThanButStillLongerThanFive"],
                applied: ["A"],
                logger: logger
            )
        }
    }

    @Test("does not trap when applied list is longer than every expected entry")
    func appliedLongerThanExpected() async {
        await #expect(processExitsWith: .success) {
            let logger = Logger(label: "postgres-migrations.test.print")
            let migrations = DatabaseMigrations()
            migrations.printMigrationComparison(
                expected: ["Short", "Tiny"],
                applied: ["AnExtremelyLongAppliedMigrationNameThatExceedsEveryExpectedEntry"],
                logger: logger
            )
        }
    }

    @Test("handles empty expected list without trapping")
    func emptyExpectedList() async {
        await #expect(processExitsWith: .success) {
            let logger = Logger(label: "postgres-migrations.test.print")
            let migrations = DatabaseMigrations()
            migrations.printMigrationComparison(
                expected: [],
                applied: ["AnythingGoes"],
                logger: logger
            )
        }
    }

    @Test("handles single long expected entry")
    func singleLongExpected() async {
        await #expect(processExitsWith: .success) {
            let logger = Logger(label: "postgres-migrations.test.print")
            let migrations = DatabaseMigrations()
            migrations.printMigrationComparison(
                expected: ["AMigrationWithAReasonablyLongIdentifier"],
                applied: [],
                logger: logger
            )
        }
    }

    @Test("handles both lists empty")
    func bothEmpty() async {
        await #expect(processExitsWith: .success) {
            let logger = Logger(label: "postgres-migrations.test.print")
            let migrations = DatabaseMigrations()
            migrations.printMigrationComparison(
                expected: [],
                applied: [],
                logger: logger
            )
        }
    }
}
#endif
