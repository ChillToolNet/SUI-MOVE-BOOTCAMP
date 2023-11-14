module game_hero::hero_test {
    use sui::test_scenario;
    use sui::coin;
    use sui::balance::{Self, Balance};
    use game_hero::hero::{Self, GameInfo, GameAdmin, Hero, Monter};
    use game_hero::sea_hero::{Self, VBI_TOKEN, SeaHeroAdmin, SeaMonster};

    #[test]
    fun test_slay_monter() {
        let manager = @0xA;
        let player = @0xB;

        // first tx, emulate module init
        let scenario_val = test_scenario::begin(manager); // addrress -> context
        let scenario = &mut scenario_val; // tx_context -> context[0]
        {
            hero::new_game(test_scenario::ctx(scenario)); // context[1]
        };

        // create hero
        test_scenario::next_tx(scenario, player);
        {
            // freeze onject -> take_immutable
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let coin1 = coin::mint_for_testing(1000, test_scenario::ctx(scenario));
            let coin2 = coin::mint_for_testing(1000, test_scenario::ctx(scenario));
            hero::acquire_hero(&game, coin1, coin2, test_scenario::ctx(scenario));
            test_scenario::return_immutable(game);
        };

        // create monter -> send to hero
        test_scenario::next_tx(scenario, manager);
        {
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            // check sender have to GameAdmin object
            let admin: GameAdmin = test_scenario::take_from_sender<GameAdmin>(scenario);
            hero::send_monter(&game, &mut admin, 10, 5, player, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, admin);
            test_scenario::return_immutable(game);
        };

        // slay
        test_scenario::next_tx(scenario, player);
        {
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let hero: Hero = test_scenario::take_from_sender<Hero>(scenario);
            let monter: Monter = test_scenario::take_from_sender<Monter>(scenario);
            hero::attack(&game, &mut hero, monter, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, hero);
            test_scenario::return_immutable(game);
        };

        test_scenario::end(scenario_val);
    }


    #[test]
    fun test_slay_sea_monter() {
        let manager = @0xA;
        let player = @0xB;

        // first tx, emulate module init
        let scenario_val = test_scenario::begin(manager); // addrress -> context
        let scenario = &mut scenario_val; // tx_context -> context[0]
        {
            hero::new_game(test_scenario::ctx(scenario)); // context[1]
            sea_hero::new_game(test_scenario::ctx(scenario));
        };

        // create hero
        test_scenario::next_tx(scenario, player);
        {
            // freeze onject -> take_immutable
            let game: GameInfo = test_scenario::take_immutable<GameInfo>(scenario);
            let coin1 = coin::mint_for_testing(1000, test_scenario::ctx(scenario));
            let coin2 = coin::mint_for_testing(1000, test_scenario::ctx(scenario));
            hero::acquire_hero(&game, coin1, coin2, test_scenario::ctx(scenario));
            test_scenario::return_immutable(game);
        };

        // create sea monter -> send to hero
        test_scenario::next_tx(scenario, manager);
        {
            let admin: SeaHeroAdmin = test_scenario::take_from_sender<SeaHeroAdmin>(scenario);
            sea_hero::create_sea_monster(&mut admin, 20, player, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, admin);
        };

        // // slay
        // test_scenario::next_tx(scenario, player);
        // {
        //     let hero: Hero = test_scenario::take_from_sender<Hero>(scenario);
        //     let monter: SeaMonster = test_scenario::take_from_sender<SeaMonster>(scenario);
        //     let reward = sea_hero::slay(&mut hero, monter);
        //     test_scenario::return_to_sender(scenario, hero);
        // };

        test_scenario::end(scenario_val);
    }
}
