
module item_gen::item_generator {        
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use std::option::{Self};
    use aptos_std::table::{Self, Table};  
    use aptos_token::token::{Self}; 
    use aptos_framework::coin;    
    use aptos_framework::event::{Self, EventHandle};
    use std::vector;
    use aptos_framework::account;    
    use item_gen::utils;

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";    
    const BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";
    const TOKEN_PROPERTY_MUTABLE: vector<u8> = b"TOKEN_PROPERTY_MUTATBLE";    

    const FEE_DENOMINATOR: u64 = 100000;
    
    // collection name / info
    const ITEM_COLLECTION_NAME:vector<u8> = b"W&W ITEM";
    const ITEM_MATERIAL_COLLECTION_NAME:vector<u8> = b"W&W ITEM MATERIAL";
    const COLLECTION_DESCRIPTION:vector<u8> = b"these items can be equipped by characters in W&W";

    const ENOT_CREATOR:u64 = 1;
    const ESAME_MATERIAL:u64 = 2;
    const ENOT_IN_RECIPE:u64 = 3;

    // property for game

    // Glimmering Crystals + Ethereal Essence = Radiant Spiritstone
    // Effect: By combining the radiant crystals with the ethereal essence, you create a Spiritstone that harnesses the power of ethereal beings. This enchanted stone can be used to augment magical weapons or create ethereal armor.

    // Glimmering Crystals + Celestial Dust = Radiant Celestite
    // Effect: By combining the radiant crystals with celestial dust, you create Radiant Celestite. This gemstone radiates celestial magic and can be used to imbue weapons with enhanced celestial properties or create powerful celestial-themed artifacts.

    // Dragon Scale + Celestial Dust = Celestial Dragon Scale
    // Effect: By infusing the mighty dragon scales with celestial dust, you forge a Celestial Dragon Scale. This rare material possesses exceptional resistance to both physical and magical attacks, granting the wearer enhanced protection against elemental forces.

    // Dragon Scale + Elemental Essence (Fire) = Inferno Scale Armor
    // Effect: By infusing the mighty dragon scales with the fiery elemental essence, you forge Inferno Scale Armor. This legendary armor provides exceptional protection against fire-based attacks and grants the wearer the ability to unleash powerful flames in combat.

    // Essence of the Ancients + Phoenix Feather = Phoenix's Elixir
    // Effect: By combining the ancient essence with the heat-resistant phoenix feathers, you create a potent elixir known as Phoenix's Elixir. This elixir grants temporary fire-based abilities to the user, enhancing their strength and resilience.

    // Moonstone Ore + Enchanted Wood = Lunar Enchanted Talisman
    // Effect: By combining the lunar-infused gemstone with enchanted wood, you craft a Lunar Enchanted Talisman. This mystical talisman enhances the wielder's magical abilities, granting them increased spellcasting prowess and the ability to channel lunar energy.

    // Kraken Ink + Elemental Essence (Water) = Ink of the Deep Seas
    // Effect: By blending the dark, iridescent kraken ink with water elemental essence, you create the Ink of the Deep Seas. This ink is used to inscribe protective runes or create powerful spell scrolls with water-based enchantments, providing the user with aquatic powers.

    // Ethereal Essence + Essence of the Ancients = Spectral Essence
    // Effect: By blending the ghostly ethereal essence with the potent Essence of the Ancients, you obtain Spectral Essence. This essence contains a combination of ethereal and ancient energies, making it a versatile substance for crafting artifacts that harness spectral powers or enhance magical abilities.

    // Phoenix Feather + Enchanted Wood = Flameheart Bow
    // Effect: By combining the heat-resistant phoenix feathers with enchanted wood, you create the Flameheart Bow. This enchanted bow channels the essence of fire, imbuing arrows with fiery properties and granting the archer enhanced precision and power in dealing with fire-aligned foes.

    // Moonstone Ore + Kraken Ink = Tidecaller Pendant
    // Effect: By combining the lunar-infused moonstone ore with the dark, iridescent kraken ink, you craft the Tidecaller Pendant. This enchanted pendant allows the wearer to command the tides and manipulate water-based magic, granting them control over aquatic forces.

    struct Recipes has key {
        recipes: Table<String, ItemComposition> // <Name of Item, Item Composition>
    }

    struct ItemComposition has key, store,drop {
        composition: vector<String>
    }

    struct ItemManager has store, key {          
        signer_cap: account::SignerCapability,                 
    } 

    struct ItemEvents has key {
        token_minting_events: EventHandle<ItemMintedEvent>,        
    }

    struct ItemMintedEvent has drop, store {
        minted_item: token::TokenId,
        generated_time: u64
    }

    fun get_resource_account_cap(minter_address : address) : signer acquires ItemManager {
        let minter = borrow_global<ItemManager>(minter_address);
        account::create_signer_with_capability(&minter.signer_cap)
    }    
    // resource cab required 
    entry fun init<WarCoinType>(sender: &signer,) {
        let sender_addr = signer::address_of(sender);                
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"01");    
        token::initialize_token_store(&resource_signer);
        if(!exists<ItemManager>(sender_addr)){            
            move_to(sender, ItemManager {                
                signer_cap,                
            });
        };

        if(!exists<Recipes>(sender_addr)){
            move_to(sender, Recipes {
                recipes: table::new()
            });
        };

        if(!coin::is_account_registered<WarCoinType>(signer::address_of(&resource_signer))){
            coin::register<WarCoinType>(&resource_signer);
        };
    }

    entry fun create_collection (
        sender: &signer, collection_uri: String, maximum_supply: u64, mutate_setting: vector<bool>
        ) {                                             
        token::create_collection(sender, string::utf8(ITEM_COLLECTION_NAME), string::utf8(COLLECTION_DESCRIPTION), collection_uri, maximum_supply, mutate_setting);
    }

    entry fun add_recipe (
        sender: &signer, item_token_name: String, material_token_name_1:String, material_token_name_2:String
        ) acquires Recipes {
        let creator_address = signer::address_of(sender);
        let minter = borrow_global_mut<Recipes>(creator_address);
        let values = vector<String>[ material_token_name_1, material_token_name_2];
        table::add(&mut minter.recipes, item_token_name, ItemComposition {
            composition: values
        });
    }

    fun check_recipe(creator_address: address, item_token_name: String, material_token_name_1:String, material_token_name_2:String) : bool acquires Recipes {        
        let minter = borrow_global_mut<Recipes>(creator_address);
        let recipe = table::borrow(&minter.recipes, item_token_name);
        let contain1 = vector::contains(&recipe.composition, &material_token_name_1);
        let contain2 = vector::contains(&recipe.composition, &material_token_name_2);
        contain1 && contain2        
    }

    entry fun remove_recipe(
        sender: &signer, item_token_name: String
        )acquires Recipes  {   
        let creator_address = signer::address_of(sender);
        let recipes = borrow_global_mut<Recipes>(creator_address);
        table::remove(&mut recipes.recipes, item_token_name);                                                 
    }
    
    // 50% success / 50% fail to mint
    // item synthesis for test item. not for pulbic
    fun mint_item (
        sender: &signer, token_name: String
    ) {        
        let creator_address = signer::address_of(sender);        
        let mutability_config = &vector<bool>[ false, true, true, true, true ];
        let collection_uri = b"https://"; // TODO URI should be filled 
        let supply_count = &mut token::get_collection_supply(creator_address, string::utf8(ITEM_COLLECTION_NAME));        
        let new_supply = option::extract<u64>(supply_count);                        
        let i = 0;
        while (i <= new_supply) {
            let new_token_name = token_name;                
            string::append_utf8(&mut new_token_name, b" #");
            let count_string = utils::to_string((i as u128));
            string::append(&mut new_token_name, count_string);                                
            if(!token::check_tokendata_exists(creator_address, string::utf8(ITEM_COLLECTION_NAME), new_token_name)) {
                token_name = new_token_name;                
                break
            };
            i = i + 1;
        };                                               
        let token_data_id = token::create_tokendata(
                sender,
                string::utf8(ITEM_COLLECTION_NAME),
                token_name,
                string::utf8(COLLECTION_DESCRIPTION),
                1, // 1 maximum for NFT 
                string::utf8(collection_uri), // TODO:: should be changed by token name
                creator_address, // royalty fee to                
                FEE_DENOMINATOR,
                FEE_DENOMINATOR * 100, // TODO:: should be check later::royalty_points_numerator
                // we don't allow any mutation to the token
                token::create_token_mutability_config(mutability_config),
                // type
                vector<String>[string::utf8(BURNABLE_BY_OWNER), string::utf8(BURNABLE_BY_CREATOR), string::utf8(TOKEN_PROPERTY_MUTABLE)],  // property_keys                
                vector<vector<u8>>[bcs::to_bytes<bool>(&true), bcs::to_bytes<bool>(&true), bcs::to_bytes<bool>(&false)],  // values 
                vector<String>[string::utf8(b"bool"),string::utf8(b"bool"), string::utf8(b"bool")],
        );
        let token_id = token::mint_token(sender, token_data_id, 1);
        token::opt_in_direct_transfer(sender, true);
        token::direct_transfer(sender, sender, token_id, 1);        
    }
    // synthesis => item systhesys by item recicpe    
    entry fun synthesis_two_item(
        sender: &signer, creator:address, target_item:String, token_name_1: String, token_name_2: String, property_version:u64
    ) acquires Recipes {
        // check collection name and creator address
        assert!(creator == @item_material_creator, ENOT_CREATOR);
        assert!(token_name_1 != token_name_2, ESAME_MATERIAL);
        
        // let token_id_1 = token::create_token_id_raw(creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_1, property_version);
        // let token_id_2 = token::create_token_id_raw(creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_2, property_version); 
        // check is in recipe
        // Glimmering Crystals + Ethereal Essence
        assert!(check_recipe(creator,target_item, token_name_1, token_name_2),ENOT_IN_RECIPE);
        token::burn(sender, creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_1, property_version, 1);
        token::burn(sender, creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_2, property_version, 1);
        
        mint_item(sender, target_item);
        // create new
        
        // give new

        // string::utf8(ITEM_COLLECTION_NAME);
    }
    // swap_owner => This is for those who are already holding their items here. Ownership information should be changed when the transfrom happend
    // vector<address>
    entry fun swap_owner(
        sender: &signer, token_name: String, new_collection_name:String, new_token_name:String
    ) {
        // check ownership by sender address sender should be holder of character token 
    }    

}
