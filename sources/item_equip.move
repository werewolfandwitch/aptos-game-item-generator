
module item_gen::item_equip {   
    use std::error; 
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use aptos_framework::account;    
    use aptos_token::token::{Self};    
    use aptos_std::table::{Self, Table};  
    use std::vector;    

    use item_gen::acl::{Self, ACL};

    // collection name / info
    const ITEM_COLLECTION_NAME:vector<u8> = b"W&W ITEM";    
    const ECONTAIN:u64 = 1;
    const ENOT_CONTAIN:u64 = 2;
    const ENOT_IN_ACL: u64 = 3;
    
    struct ItemHolder has store, key {          
        signer_cap: account::SignerCapability,
        acl: acl::ACL                  
    }

    struct ItemReciept has store, copy, drop {
        owner: address,
        token_name:String,
        collectin_name:String,
        item_creator:address
    }    


    struct ItemEquipEvent has drop, store {
        owner: address,
        token_name:String,
        collectin_name:String,
        item_creator:address
    }

    struct ItemUnEquipEvent has drop, store {
        owner: address,
        token_name:String,
        collectin_name:String,
        item_creator:address
    }

    fun get_resource_account_cap(minter_address : address) : signer acquires ItemHolder {
        let minter = borrow_global<ItemHolder>(minter_address);
        account::create_signer_with_capability(&minter.signer_cap)
    }    

    fun is_in_acl(sender_addr:address) : bool acquires ItemHolder {
        let manager = borrow_global<ItemHolder>(sender_addr);
        let acl = manager.acl;        
        acl::contains(&acl, sender_addr)
    }

    entry fun init (sender: &signer) acquires ItemHolder {
        let sender_addr = signer::address_of(sender);
        let (resource_signer, signer_cap) = account::create_resource_account(sender, x"03");    
        token::initialize_token_store(&resource_signer);
        if(!exists<ItemHolder>(sender_addr)){            
            move_to(sender, ItemHolder {                
                signer_cap,
                acl: acl::empty()               
            });
        };        
        let manager = borrow_global_mut<ItemHolder>(sender_addr);
        let acl = manager.acl;        
        acl::add(&mut acl, sender_addr);
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
        // acl required
        // create a ItemReciept
        // emit equip item
    }

    public fun item_unequip (
        sender: &signer, token_name: String, description:String,
    ) {                     
        // acl required
        // emit unequip item        
        // remove a ItemReciept
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

