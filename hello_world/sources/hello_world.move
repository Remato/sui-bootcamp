module hello_world::hello_world {
  use std::debug::print;
  use std::string::utf8;

  fun hello() {
    print(&utf8(b"Hello world! Sui Bootcamp 2025."));
  }
  
  #[test]
  fun test_hello() {
    hello();
  }
}




