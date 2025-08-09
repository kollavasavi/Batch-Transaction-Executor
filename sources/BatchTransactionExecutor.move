module vasavi_addr::BatchExecutor {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

   
    struct BatchTransactionData has store, key {
        total_transactions: u64,
        total_amount_processed: u64,
        is_active: bool,
    }

   
    struct Transaction has store, drop {
        recipient: address,
        amount: u64,
    }

    
    public fun initialize_batch_executor(account: &signer) {
        let batch_data = BatchTransactionData {
            total_transactions: 0,
            total_amount_processed: 0,
            is_active: true,
        };
        move_to(account, batch_data);
    }

   
    public fun execute_batch_transactions(
        sender: &signer,
        recipients: vector<address>,
        amounts: vector<u64>
    ) acquires BatchTransactionData {
        let sender_addr = signer::address_of(sender);
        let batch_data = borrow_global_mut<BatchTransactionData>(sender_addr);
        
     
        assert!(batch_data.is_active, 1);
        
       
        let recipients_len = vector::length(&recipients);
        let amounts_len = vector::length(&amounts);
        assert!(recipients_len == amounts_len, 2);
        
        let i = 0;
        let total_batch_amount = 0;
        
       
        while (i < recipients_len) {
            let recipient = *vector::borrow(&recipients, i);
            let amount = *vector::borrow(&amounts, i);
            
       
            let payment = coin::withdraw<AptosCoin>(sender, amount);
            coin::deposit<AptosCoin>(recipient, payment);
            
            total_batch_amount = total_batch_amount + amount;
            i = i + 1;
        };
        
      
        batch_data.total_transactions = batch_data.total_transactions + recipients_len;
        batch_data.total_amount_processed = batch_data.total_amount_processed + total_batch_amount;
    }

}
