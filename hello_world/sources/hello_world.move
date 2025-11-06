module hello_world::hello_world {
  use std::string;

  public struct Greeting has key {
    id: UID,
    text: string::String,
  }

  public fun hello(ctx: &mut TxContext) { 
    let new_greeting = Greeting { 
      id: object::new(ctx),
      text: b"Hello world! Sui Bootcamp 2025.".to_string()
    };
    transfer::share_object(new_greeting);
  }
}




