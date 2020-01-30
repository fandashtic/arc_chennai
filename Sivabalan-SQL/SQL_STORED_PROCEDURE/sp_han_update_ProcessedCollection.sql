Create Procedure sp_han_update_ProcessedCollection(@SerialNO nvarchar(50),@Flag Integer, @CollectionID integer = 0)  
AS  
Declare @NoRecs as Integer, @PaymentID nvarchar(50)  
 -- CollectionID has been added to identify the Implicit Colletion created based on PDA data     
 Update Collection_Details set Processed = @Flag  
 , CollectionID = @CollectionID  
 where Collection_Serial = @SerialNO  
  
 Set @NoRecs  = @@ROWCOUNT  
  
 If @NoRecs  <> 0 and @Flag = 1  
 Begin  
  -- PaymentID has been updated to have the Integration based on single ID    
  Select Top 1 @PaymentID = (Case when Isnull(PaymentID, '') = '' then @SerialNO else PaymentID end)   
  from Collection_Details Where Collection_Serial = @SerialNO  
  Update Collection_Action Set Integration_ID = @PaymentID Where CollectionID = @CollectionID  
  
  --Copy table for LOG  
  Insert Into Collection_Details_Copy  
  ([COLLECTION_SERIAL],[AGAINSTBILLNO],[CUSTOMERID],[SALESMANID],[BEATID],[COLLECTIONDATE],[COLLECTIONTYPE],[COLLECTIONFLAG]  
  ,[AMOUNTCOLLECTED],[DISCOUNT],[CHEQNO_DDNO],[CHEQDATE_DDDATE],[BANKCODE],[BRANCHCODE],[PROCESSED],[CREATIONDATE]  
  ,[CollectionID], [PAYMENTID])  
  Select [COLLECTION_SERIAL],[AGAINSTBILLNO],[CUSTOMERID],[SALESMANID],[BEATID],[COLLECTIONDATE],[COLLECTIONTYPE],[COLLECTIONFLAG]  
  ,[AMOUNTCOLLECTED],[DISCOUNT],[CHEQNO_DDNO],[CHEQDATE_DDDATE],[BANKCODE],[BRANCHCODE],[PROCESSED],GETDATE()  
  ,[COLLECTIONID], [PAYMENTID]  
   from Collection_details where Collection_Serial = @SerialNo  
 end   
 Select "Rows" =  @NoRecs    

