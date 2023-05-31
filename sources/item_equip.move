
module item_gen::item_equip {   
    use std::error; 
    use std::bcs;
    use std::signer;    
    use std::string::{Self, String};    
    use aptos_framework::account;    
    use aptos_token::token::{Self};    
    use aptos_std::table::{Self, Table};  
    use std::vector;

    // collection name / info
    const ITEM_COLLECTION_NAME:vector<u8> = b"W&W ITEM";    
    const ECONTAIN:u64 = 1;
    const ENOT_CONTAIN:u64 = 2;
    
    struct ACL has store, drop, copy {
        list: vector<address>
    }

    /// Return an empty ACL.
    public fun empty(): ACL {
        ACL{ list: vector::empty<address>() }
    }

    /// Add the address to the ACL.
    public fun add(acl: &mut ACL, addr: address) {
        assert!(!vector::contains(&mut acl.list, &addr), error::invalid_argument(ECONTAIN));
        vector::push_back(&mut acl.list, addr);
    }

    /// Remove the address from the ACL.
    public fun remove(acl: &mut ACL, addr: address) {
        let (found, index) = vector::index_of(&mut acl.list, &addr);
        assert!(found, error::invalid_argument(ENOT_CONTAIN));
        vector::remove(&mut acl.list, index);
    }

    /// Return true iff the ACL contains the address.
    public fun contains(acl: &ACL, addr: address): bool {
        vector::contains(&acl.list, &addr)
    }

    /// assert! that the ACL has the address.
    public fun assert_contains(acl: &ACL, addr: address) {
        assert!(contains(acl, addr), error::invalid_argument(ENOT_CONTAIN));
    }

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

