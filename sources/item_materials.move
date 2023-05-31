
module nft_war::item_materials {    
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    
    use aptos_token::token::{Self};    

    const BURNABLE_BY_CREATOR: vector<u8> = b"TOKEN_BURNABLE_BY_CREATOR";    
    const BURNABLE_BY_OWNER: vector<u8> = b"TOKEN_BURNABLE_BY_OWNER";
    const TOKEN_PROPERTY_MUTABLE: vector<u8> = b"TOKEN_PROPERTY_MUTATBLE";    

    const FEE_DENOMINATOR: u64 = 100000;

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
    
    entry fun create_collection<CoinType> (
        sender: &signer,                
        collection_uri: String, maximum_supply: u64, mutate_setting: vector<bool>
        ) {                                             
        token::create_collection(sender, string::utf8(ITEM_MATERIAL_COLLECTION_NAME), string::utf8(COLLECTION_DESCRIPTION), collection_uri, maximum_supply, mutate_setting);
    }

    entry fun mint_item_material (
        sender: &signer, token_name: String, royalty_points_numerator:u64, description:String, collection_uri:String, max_amount:u64, amount:u64
    ) {        
        let creator_address = signer::address_of(sender);        
        let mutability_config = &vector<bool>[ true, true, false, true, true ];              
        let token_data_id = token::create_tokendata(
                sender,
                string::utf8(ITEM_MATERIAL_COLLECTION_NAME),
                token_name,
                description,
                max_amount, 
                collection_uri,
                creator_address, // royalty fee to                
                FEE_DENOMINATOR,
                royalty_points_numerator,
                // we don't allow any mutation to the token
                token::create_token_mutability_config(mutability_config),
                // type
                vector<String>[string::utf8(BURNABLE_BY_OWNER),string::utf8(TOKEN_PROPERTY_MUTABLE)],  // property_keys                
                vector<vector<u8>>[bcs::to_bytes<bool>(&true),bcs::to_bytes<bool>(&false)],  // values 
                vector<String>[string::utf8(b"bool"),string::utf8(b"bool")],
        );
        let token_id = token::mint_token(sender, token_data_id, amount);
        token::opt_in_direct_transfer(sender, true);
        token::direct_transfer(sender, sender, token_id, 1);        
    }  
}

