CREATE PROCEDURE sp_han_InsertErrorlog(         
     @tranID  nvarchar(50),        
     @transType Int,        
     @msgType nVarchar(50),        
     @msgAction nVarchar(50),  
     @msgDesc nVarchar(2000),        
     @salesmanId nVarchar(100))   		
AS        
If Not exists ( select * from SyncError where TRANSACTIONID = @tranID and TRANSACTIONTYPE = @transType and MSGACTION = 'Processed' ) 
INSERT INTO SyncError(TRANSACTIONID, TRANSACTIONTYPE, MSGTYPE, MSGACTION, MSGDESCRIPTION,SALESMANID)   
VALUES(@tranID, @transType, @msgType, @msgAction, @msgDesc,@salesmanId)  
