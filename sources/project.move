module MyModule::TokenAirdrop {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing an airdrop campaign
    struct AirdropCampaign has store, key {
        tokens_per_user: u64,        // Amount of tokens each user gets
        claimed_users: vector<address>, // List of users who already claimed
    }

    /// Function to initialize an airdrop campaign
    public fun create_airdrop(
        creator: &signer, 
        tokens_per_user: u64
    ) {
        // Create the airdrop campaign
        let campaign = AirdropCampaign {
            tokens_per_user,
            claimed_users: vector::empty<address>(),
        };

        // Store the campaign under creator's account
        move_to(creator, campaign);
    }

    /// Function for users to claim their airdrop tokens
    /// The creator must call this function to distribute tokens
    public fun distribute_airdrop(
        creator: &signer,
        recipient: address
    ) acquires AirdropCampaign {
        let creator_addr = signer::address_of(creator);
        let campaign = borrow_global_mut<AirdropCampaign>(creator_addr);

        // Check if user has already claimed
        assert!(
            !vector::contains(&campaign.claimed_users, &recipient),
            2 // Error code: Already claimed
        );

        // Check if creator has enough tokens
        assert!(
            coin::balance<AptosCoin>(creator_addr) >= campaign.tokens_per_user,
            3 // Error code: Insufficient tokens
        );

        // Transfer tokens from creator to recipient
        let tokens = coin::withdraw<AptosCoin>(creator, campaign.tokens_per_user);
        coin::deposit<AptosCoin>(recipient, tokens);

        // Update campaign state
        vector::push_back(&mut campaign.claimed_users, recipient);
    }
}