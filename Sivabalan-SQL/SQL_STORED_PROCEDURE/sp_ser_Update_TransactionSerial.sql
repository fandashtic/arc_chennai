CREATE procedure sp_ser_Update_TransactionSerial (@TranType int, @DocType Varchar(100))    
As    
Declare @LastCount int
BEGIN TRAN    
	UPDATE TransactionDocNumber SET LastCount = LastCount + 1   
	WHERE TransactionType = @Trantype And DocumentType=@DOCTYPE    
	SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber 
	WHERE TransactionType = @Trantype And DocumentType=@DOCTYPE	
COMMIT TRAN    
select @LastCount 'LastCount'

