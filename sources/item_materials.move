
module item_gen::item_materials {    
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use aptos_framework::account;    
    use aptos_token::token::{Self};
    use item_gen::acl::{Self, ACL};    
    use aptos_framework::coin;

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";    
    const BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";
    const TOKEN_PROPERTY_MUTABLE: vector<u8> = b"TOKEN_PROPERTY_MUTATBLE";    

    const FEE_DENOMINATOR: u64 = 100000;

    const ENOT_IN_ACL: u64 = 1;

    // collection name / info
    const ITEM_MATERIAL_COLLECTION_NAME:vector<u8> = b"W&W ITEM MATERIAL";
    const COLLECTION_DESCRIPTION:vector<u8> = b"These materials are used for item synthesis in W&W";

    // property for game

    const MATERIAL_A: vector<u8> = b"Glimmering Crystals";
    const MATERIAL_B: vector<u8> = b"Ethereal Essence";
    const MATERIAL_C: vector<u8> = b"Dragon Scale";
    const MATERIAL_D: vector<u8> = b"Celestial Dust";
    const MATERIAL_E: vector<u8> = b"Essence of the Ancients";
    const MATERIAL_F: vector<u8> = b"Phoenix Feather";
    const MATERIAL_G: vector<u8> = b"Moonstone Ore";
    const MATERIAL_H: vector<u8> = b"Enchanted Wood";
    const MATERIAL_I: vector<u8> = b"Elemental Essence";

    //!! Item material description

    // Glimmering Crystals: These rare and radiant crystals are found deep within ancient caves. They emit a soft, enchanting glow and are a key ingredient in crafting powerful magical artifacts.

    // Ethereal Essence: A ghostly substance that can only be collected from the spirits of ethereal beings. It possesses a faint shimmer and is often used in creating ethereal weapons or enchanted armor.

    // Dragon Scale: The scales of mighty dragons, known for their durability and resistance to fire. Dragon scales are highly sought after for forging powerful armor and shields that provide exceptional protection against elemental attacks.

    // Celestial Dust: A fine, shimmering powder collected from fallen stars. Celestial dust is imbued with celestial magic and can be used to enchant weapons and create celestial-themed jewelry.

    // Essence of the Ancients: A rare substance extracted from ancient ruins or the remnants of ancient creatures. It contains potent magical energy and is often used in creating legendary artifacts or enhancing existing ones.

    // Phoenix Feather: Feathers shed by phoenixes, mythical birds of fire and rebirth. These feathers possess incredible heat resistance and are used in crafting flame-resistant equipment or items that grant temporary fire-based abilities.

    // Moonstone Ore: A precious gemstone that can only be mined during a full moon. Moonstone ore has lunar magic infused within it and is used to create enchanted jewelry or enhance magical staves.

    // Enchanted Wood: Wood harvested from mystical forests inhabited by sentient trees. This wood retains magical properties and is ideal for crafting wands, bows, and staves.

    // Kraken Ink: An ink harvested from the mighty krakens of the deep sea. It possesses a dark, iridescent sheen and is used in the creation of powerful spell scrolls or to inscribe protective runes.

    // Elemental Essence: Essence drawn from the elemental planes. Each elemental essence (fire, water, earth, air) grants specific properties and can be used in alchemy or enchanting to imbue items with elemental attributes.    

    struct ItemMaterialManager has store, key {          
        signer_cap: account::SignerCapability,                 
        acl: acl::ACL
    } 

    entry fun admin_withdraw<CoinType>(sender: &signer, amount: u64) acquires ItemMaterialManager {
        let sender_addr = signer::address_of(sender);
        let resource_signer = get_resource_account_cap(sender_addr);                                
        let coins = coin::withdraw<CoinType>(&resource_signer, amount);                
        coin::deposit(sender_addr, coins);
    }

    fun get_resource_account_cap(minter_address : address) : signer acquires ItemMaterialManager {
        let minter = borrow_global<ItemMaterialManager>(minter_address);
        account::create_signer_with_capability(&minter.signer_cap)
    }    

    entry fun add_acl(sender: &signer, addr:address) acquires ItemMaterialManager {
        let sender_addr = signer::address_of(sender);                
        let manager = borrow_global<ItemMaterialManager>(sender_addr);
        let acl = manager.acl;        
        acl::add(&mut acl, addr);
    }

    fun is_in_acl(sender_addr:address) : bool acquires ItemMaterialManager {
        let manager = borrow_global<ItemMaterialManager>(sender_addr);
        let acl = manager.acl;        
        acl::contains(&acl, sender_addr)
    }
    // resource cab required 
    entry fun init(sender: &signer,collection_uri: String,maximum_supply:u64) acquires ItemMaterialManager {
        let sender_addr = signer::address_of(sender);                
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"02");    
        token::initialize_token_store(&resource_signer);
        if(!exists<ItemMaterialManager>(sender_addr)){            
            move_to(sender, ItemMaterialManager {                
                signer_cap,  
                acl: acl::empty()                             
            });
        };                
        let mutate_setting = vector<bool>[ true, true, true ]; // TODO should check before deployment.
        token::create_collection(&resource_signer, 
            string::utf8(ITEM_MATERIAL_COLLECTION_NAME), 
            string::utf8(COLLECTION_DESCRIPTION), collection_uri, maximum_supply, mutate_setting);        
        let manager = borrow_global_mut<ItemMaterialManager>(sender_addr);
        let acl = manager.acl;        
        acl::add(&mut acl, sender_addr);
    }        


    entry fun mint_item_material (
        sender: &signer, 
        minter_address:address, 
        token_name: String, 
        royalty_points_numerator:u64, 
        description:String, 
        collection_uri:String, max_amount:u64, amount:u64
    ) acquires ItemMaterialManager {             
        let sender_address = signer::address_of(sender);     
        assert!(is_in_acl(sender_address), ENOT_IN_ACL);
        let resource_signer = get_resource_account_cap(minter_address);                
        
        let mutability_config = &vector<bool>[ true, true, false, true, true ];              
        let token_data_id = token::create_tokendata(
                &resource_signer,
                string::utf8(ITEM_MATERIAL_COLLECTION_NAME),
                token_name,
                description,
                max_amount, // 1 for NFT
                collection_uri,
                minter_address, // royalty fee to                
                FEE_DENOMINATOR,
                royalty_points_numerator,
                // we don't allow any mutation to the token
                token::create_token_mutability_config(mutability_config),
                // type
                vector<String>[string::utf8(BURNABLE_BY_OWNER),string::utf8(TOKEN_PROPERTY_MUTABLE)],  // property_keys                
                vector<vector<u8>>[bcs::to_bytes<bool>(&true),bcs::to_bytes<bool>(&false)],  // values 
                vector<String>[string::utf8(b"bool"),string::utf8(b"bool")],
        );
        let token_id = token::mint_token(&resource_signer, token_data_id, amount);
        token::opt_in_direct_transfer(sender, true);
        token::direct_transfer(&resource_signer, sender, token_id, 1);        
    }    
}

