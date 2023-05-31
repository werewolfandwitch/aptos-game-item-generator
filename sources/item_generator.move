
module item_gen::item_generator {        
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use aptos_std::table::{Self, Table};  
    use aptos_token::token::{Self}; 
    use aptos_framework::coin;    
    use aptos_framework::event::{Self, EventHandle};
    use std::vector;
    use aptos_framework::account;    

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

    entry fun remove_recipe(
        sender: &signer, item_token_name: String
        )acquires Recipes  {   
        let creator_address = signer::address_of(sender);
        let minter = borrow_global_mut<Recipes>(creator_address);
        table::remove(&mut minter.recipes, item_token_name);                                                 
    }
    
    // 50% success / 50% fail to mint
    // item synthesis
    fun mint_item (
        sender: &signer, token_name: String, royalty_points_numerator:u64, collection_uri:String, max_amount:u64, amount:u64
    ) {        
        let creator_address = signer::address_of(sender);        
        let mutability_config = &vector<bool>[ false, true, true, true, true ];
        let token_data_id = token::create_tokendata(
                sender,
                string::utf8(ITEM_COLLECTION_NAME),
                token_name,
                string::utf8(COLLECTION_DESCRIPTION),
                max_amount, // 1 maximum for NFT 
                collection_uri,
                creator_address, // royalty fee to                
                FEE_DENOMINATOR,
                royalty_points_numerator,
                // we don't allow any mutation to the token
                token::create_token_mutability_config(mutability_config),
                // type
                vector<String>[string::utf8(BURNABLE_BY_OWNER),string::utf8(BURNABLE_BY_CREATOR), string::utf8(TOKEN_PROPERTY_MUTABLE)],  // property_keys                
                vector<vector<u8>>[bcs::to_bytes<bool>(&true), bcs::to_bytes<bool>(&true), bcs::to_bytes<bool>(&false)],  // values 
                vector<String>[string::utf8(b"bool"),string::utf8(b"bool"), string::utf8(b"bool")],
        );
        let token_id = token::mint_token(sender, token_data_id, amount);
        token::opt_in_direct_transfer(sender, true);
        token::direct_transfer(sender, sender, token_id, 1);        
    }
    // synthesis => item systhesys by item recicpe    
    entry fun synthesis_two_item(
        sender: &signer, creator:address, token_name_1: String, property_version:u64, token_name_2: String
    ) {
        // check collection name and creator address
        assert!(creator == @item_material_creator, ENOT_CREATOR);
        assert!(token_name_1 != token_name_2, ESAME_MATERIAL);
        
        let token_id_1 = token::create_token_id_raw(creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_1, property_version);
        let token_id_2 = token::create_token_id_raw(creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_2, property_version); 
        // check is in recipe
        // Glimmering Crystals + Ethereal Essence

        token::burn(sender, creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_1, property_version, 1);
        token::burn(sender, creator, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), token_name_2, property_version, 1);

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
