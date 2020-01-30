
CREATE Procedure sp_Save_SVAbstract                      
(                        
 @SVDate DateTime,@DeliveryDate DateTime,@Value Decimal(18, 6),@CustomerID NVarChar(15),                      
 @BillingAddress NVarChar(255),@ShippingAddress NVarChar(255),@CreditTerm Int,                      
 @SalesmanCode NVarChar(15),@BeatID Int,@DocRef NVarChar(255),@SVRef Int,                      
 @OHDPre Int,@IsAmEnd Int,@SalesmanRemarks NVarChar(2000)
)                      
AS                        
                      
Declare @DocumentID Int                        
Declare @Status Int                      
                        
If(@IsAmEnd=0)                        
	Begin                
	 Set @Status = 0                              
	 Begin Tran                        
	 	Update DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 62                        
		 Select @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 62                        
	 Commit Tran                        
	End                        
Else                        
	Begin                      
	 Set @Status = 16                       
	 Select @DocumentID=DocumentID From SVAbstract Where SVNumber=@SVRef                        
	End                        
                       
Insert Into SVAbstract                      
(                      
 SVDate,DeliveryDate,Value,CustomerID,BillingAddress,ShippingAddress,Status,CreditTerm,                      
 SalesmanCode,BeatID,DocRef,DocumentID,SvRef,CreationTime,OHDPre,SalesmanRemarks     
)                      
Values                      
(                      
 @SVDate,@DeliveryDate,@Value,@CustomerID,@BillingAddress,@ShippingAddress,@Status,@CreditTerm,                      
 @SalesmanCode,@BeatID,@DocRef,@DocumentID,@SvRef,GetDate(),@OHDPre,@SalesmanRemarks                  
)                          
                        
Select @@Identity, @DocumentID

