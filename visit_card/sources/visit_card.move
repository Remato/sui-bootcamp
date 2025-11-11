module visit_card::visit_card {

    use std::string::{Self, String};

    public struct VisitCard has key, store {
        id: UID,
        name: String,
        email: String,
        github: String,
        company: String
    }

    entry fun create_card(
        name: vector<u8>,
        email: vector<u8>,
        github: vector<u8>,
        company: vector<u8>,
        ctx: &mut TxContext
    ) {
        let new_card = VisitCard {
            id: object::new(ctx),
            name: string::utf8(name),
            email: string::utf8(email),
            github: string::utf8(github),
            company: string::utf8(company)
        };

        transfer::transfer(new_card, tx_context::sender(ctx));
    }
}