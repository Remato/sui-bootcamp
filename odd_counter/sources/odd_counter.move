module odd_counter::odd_counter {
  use std::debug::print;
  use std::string::utf8;

  public struct Counter has drop {
    current: u64,
    target: u64,
    odds: u64,
  }

  #[error]
  const ECOUNTER_OVERFLOW: u8 = 1;

  fun new(target: u64): Counter {
    Counter { current: 0, odds: 0, target: target }
  }

  fun increment(counter: &mut Counter){
    assert!(counter.current < counter.target, ECOUNTER_OVERFLOW);
    if(counter.current % 2 != 0) {
      counter.odds = counter.odds + 1;
    };
    counter.current = counter.current + 1;
  }

  fun get_current(counter: &Counter): u64 {
    // print(&counter.current);    
    counter.current
  }

  fun is_completed(counter: &Counter): bool {
    counter.current == counter.target
  }

  fun reset(counter: &mut Counter) {
    counter.current = 0
  }

  fun play_counter(counter: &mut Counter): () {
    while (!is_completed(counter)) {
      get_current(counter);
      increment(counter);
    };
    print(&utf8(b"Final odds:"));
    print(&counter.odds); 
    reset(counter);
  }

  #[test]
  fun test_main(){
    let mut counter = new(330);
    play_counter(&mut counter)
  }
}
