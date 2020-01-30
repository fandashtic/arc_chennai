CREATE procedure sp_update_GiftVoucherDetail(@IssueDate DateTime,  
    @AmountReceived Decimal(18,6),@CustomerID NVarchar(50),@SerialNo Int,@Status Int)  
As  
Update GiftVoucherDetail Set IssueDate= @IssueDate,  
        AmountReceived = @AmountReceived,  
                             CustomerID= @CustomerID,  
        Status=Status | @Status  
        Where SerialNo= @SerialNo  
  


