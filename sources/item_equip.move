
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
    // keep item in resource account with claim receipt
    entry fun item_equip (
        sender: &signer,                
        token_name: String, description:String, collection:String
        ) {                                                     
    }
    // remove claim receipt and give back to sender item
    entry fun item_unequip (
        sender: &signer, token_name: String, description:String,
    ) {                     
    }  
}

