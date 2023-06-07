
module item_gen::item_equip {   
    use std::error; 
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use aptos_framework::account;    
    use aptos_token::token::{Self};    
    use aptos_std::table::{Self, Table};  
    use std::vector;

    use item_gen::acl;

    // collection name / info
    const ITEM_COLLECTION_NAME:vector<u8> = b"W&W ITEM";    
    const ECONTAIN:u64 = 1;
    const ENOT_CONTAIN:u64 = 2;
    
    struct ItemHolder has store, key {          
        signer_cap: account::SignerCapability,                 
    }
    struct AuthorizedAddress has key {
        auth_table: Table<address, bool> 
    }

    entry fun init(sender: &signer) {
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
        // upsert table true with address. give authorized
    }

    entry fun remove_auth() {
        // upsert table false with address. remove authorized
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
    // swap_owner => This is for those who are already holding their items here. Ownership information should be changed when the transfrom happend
    // vector<address>
    entry fun swap_owner(
        sender: &signer, token_name: String, 
        new_collection_name:String, // werewolf and witch collection name
        new_token_name:String // 
    ) {
        // check ownership by sender address sender should be holder of character token 
    }  
}

