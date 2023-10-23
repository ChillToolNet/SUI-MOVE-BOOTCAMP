module lesson6::hero_game {
    use std::option::{Self, Option};
    use std::string::String;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::transfer;
    use lesson6::random::rand_u64_range;

    struct Hero has key, store {
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
        sword: Option<Sword>,
        armor: Option<Armor>,
        game_id: ID
    }

    struct Sword  has key, store {
        id: UID,
        strenght: u64,
        game_id: ID
    }

    struct Armor has key, store {
        id: UID,
        defense: u64,
        game_id: ID
    }

    // struct Monter has key, store{
    //     id: UID,
    //     hp: u64,
    //     strenght: u64,
    // }

    struct GameInfo has key {
        id: UID,
        admin: address
    }

    struct GameAdmin has key {
        id: UID,
        game_id: ID,
        monters: u64
    }

    fun new_game(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);
        transfer::freeze_object(GameInfo {
            id,
            admin: sender
        });
        transfer::transfer(GameAdmin {
            id: object::new(ctx),
            game_id,
            monters: 0
        }, sender);
    }

    fun init(ctx: &mut TxContext) {
        new_game(ctx);
    }

    public fun get_game_id(gameinfo: &GameInfo): ID {
        object::id(gameinfo)
    }

    public fun create_hero(game: &GameInfo, name: String, ctx: &mut TxContext): Hero {
        Hero {
            id: object::new(ctx),
            name,
            hp: 100,
            experience: 0,
            sword: option::none(),
            armor: option::none(),
            game_id: get_game_id(game)
        }
    }

    /// Price for Sword
    const SWORD_PRICE: u64 = 1;
    /// Price for Armor
    const ARMOR_PRICE: u64 = 1;
    /// Not enough funds to pay for the good in question
    const EInsufficientFunds: u64 = 0;

    public fun create_sword(game: &GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Sword {
        let value = coin::value(&payment);
        assert!(value >= SWORD_PRICE, EInsufficientFunds);
        transfer::public_transfer(payment, game.admin);
        let strenght = rand_u64_range(10, 20, ctx);
        Sword {
            id: object::new(ctx),
            strenght,
            game_id: get_game_id(game)
        }
    }

    public fun create_armor(game: &GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Armor {
        let value = coin::value(&payment);
        assert!(value >= ARMOR_PRICE, EInsufficientFunds);
        transfer::public_transfer(payment, game.admin);
        let defense = rand_u64_range(10, 20, ctx);
        Armor {
            id: object::new(ctx),
            defense,
            game_id: get_game_id(game)
        }
    }
}