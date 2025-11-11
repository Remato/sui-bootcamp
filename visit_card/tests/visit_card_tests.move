
#[test_only]
module visit_card::visit_card_tests;
// uncomment this line to import the module
// use visit_card::visit_card;

const ENotImplemented: u64 = 0;

#[test]
fun test_visit_card() {
    // pass
}

#[test, expected_failure(abort_code = ::visit_card::visit_card_tests::ENotImplemented)]
fun test_visit_card_fail() {
    abort ENotImplemented
}

