module crowdfunding::vakinha {
  use sui::coin::{Self, Coin};
  use sui::balance::{Self, Balance};
  use std::string::String;

  // USDC on Sui (mainet)
  // use 0xdba34672e30cb065b1f93e3ab55318768fd6fef66c15942c9f7cb846e2f900e7::usdc::USDC

  // USDC mock (devnet/testnet)
  public struct USDC has drop {}

  /// Vakinha -> need acept ONLY USDC
  public struct Campaign has key {
    id: UID,
    title: String,
    description: String,
    contact: String,
    author: address,           
    goal: u64,                 // 1 USDC = 1_000_000)
    balance: Balance<USDC>,
    is_open: bool,            
    created_at: u64           
  }

  /// Proof of donate
  public struct DonationReceipt has key, store {
    id: UID,
    campaign_id: ID,
    donor: address,
    amount: u64,
    timestamp: u64
  }

  /// Possible errors
  const EGoalMustBeGreaterThanZero: u64 = 1;
  const ECampaignIsClosed: u64 = 2;
  const ENotAuthor: u64 = 3;
  const EInvalidDonationAmount: u64 = 4;
  const EGoalNotReached: u64 = 5;

  public fun create_campaign(
    title: String,
    description: String,
    contact: String,
    goal: u64,
    clock: &sui::clock::Clock,
    ctx: &mut TxContext
  ) {
    assert!(goal > 0, EGoalMustBeGreaterThanZero);

    let new_campaign = Campaign {
      id: object::new(ctx),
      title,
      description,
      contact,
      author: tx_context::sender(ctx),
      goal,
      balance: balance::zero<USDC>(),
      is_open: true,
      created_at: sui::clock::timestamp_ms(clock)
    };

    transfer::share_object(new_campaign);
  }

  // donate and return proof of donate (NFT) -> for external contracts
  public fun donate(
    campaign: &mut Campaign,
    payment: Coin<USDC>,
    clock: &sui::clock::Clock,
    ctx: &mut TxContext
  ): DonationReceipt {
    assert!(campaign.is_open, ECampaignIsClosed);
    let amount = coin::value(&payment);
    assert!(amount > 0, EInvalidDonationAmount);

    // Movee USDC to balance
    let coin_balance = coin::into_balance(payment);
    balance::join(&mut campaign.balance, coin_balance);

    // Create a proof of donate
    let receipt = DonationReceipt {
      id: object::new(ctx),
      campaign_id: object::id(campaign),
      donor: tx_context::sender(ctx),
      amount,
      timestamp: sui::clock::timestamp_ms(clock)
    };

    // Closes if goal is met
    if (balance::value(&campaign.balance) >= campaign.goal) {
      campaign.is_open = false;
    };

    receipt
  }

  /// Donate and send NFT direct to donor wallet
  entry fun donate_and_keep_receipt(
    campaign: &mut Campaign,
    payment: Coin<USDC>,
    clock: &sui::clock::Clock,
    ctx: &mut TxContext
  ) {
    let receipt = donate(campaign, payment, clock, ctx);
    transfer::transfer(receipt, tx_context::sender(ctx));
  }

  public fun withdraw(
    campaign: &mut Campaign,
    ctx: &mut TxContext
  ) {
    assert!(tx_context::sender(ctx) == campaign.author, ENotAuthor);
    assert!(!campaign.is_open, ECampaignIsClosed);
    
    let current_balance = balance::value(&campaign.balance);
    assert!(current_balance >= campaign.goal, EGoalNotReached);

    // withdraw all balance and send to owner
    let amount = balance::withdraw_all(&mut campaign.balance);
    let coin = coin::from_balance(amount, ctx);
    
    transfer::public_transfer(coin, campaign.author);
  }
  
  public fun close_campaign(
    campaign: &mut Campaign,
    ctx: &mut TxContext
  ) {
    assert!(tx_context::sender(ctx) == campaign.author, ENotAuthor);
    assert!(campaign.is_open, ECampaignIsClosed);
    

    // refund here
    campaign.is_open = false;
  }

  /// return in micro USDC 1_000_000
  public fun get_balance(campaign: &Campaign): u64 {
    balance::value(&campaign.balance)
  }

  /// return in micro USDC 1_000_000
  public fun get_goal(campaign: &Campaign): u64 {
    campaign.goal
  }

  public fun is_open(campaign: &Campaign): bool {
    campaign.is_open
  }

  public fun get_author(campaign: &Campaign): address {
    campaign.author
  }

  /// between 0 and 100+
  public fun get_progress_percentage(campaign: &Campaign): u64 {
    let current = balance::value(&campaign.balance);
    if (campaign.goal == 0) return 0;
    
    (current * 100) / campaign.goal
  }

  // ==========================================
  // UTILS
  // ==========================================

  /// USDC to micro USDC
  /// usdc_to_micro(100) = 100_000_000 (100 USDC)
  public fun usdc_to_micro(usdc_amount: u64): u64 {
    usdc_amount * 1_000_000
  }

  /// micro USDC to USDC
  /// micro_to_usdc(100_000_000) = 100 (100 USDC)
  public fun micro_to_usdc(micro_amount: u64): u64 {
    micro_amount / 1_000_000
  }
}