
module nft_war::item_equip {    
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    
    use aptos_token::token::{Self};    

    // collection name / info
    const ITEM_COLLECTION_NAME:vector<u8> = b"W&W ITEM";    

    struct ItemHolder has store, key {          
        signer_cap: account::SignerCapability,                 
    }
    struct AuthorizedAddress has key {
        auth_table: Table<address, bool> 
    }

    entry fun init() {
        let sender_addr = signer::address_of(sender);
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"01");    
        token::initialize_token_store(&resource_signer);
        if(!exists<ItemHolder>(sender_addr)){            
            move_to(sender, ItemHolder {                
                signer_cap,                
            });
        };        
    }

    entry fun add_auth() {
        // upsert table true with address.
    }

    entry fun remove_auth() {
        // upsert table false with address.
    }
    // keep item in resource account with claim receipt
    // sender address should be season contract address for authorization
    entry fun item_equip (
        sender: &signer,token_name: String, description:String, collection:String
        ) {                                                     
    }
    // remove claim receipt and give back to sender item
    // sender address should be season contract address for authorization
    entry fun item_unequip (
        sender: &signer, token_name: String, description:String,
    ) {                     
    }  
}

