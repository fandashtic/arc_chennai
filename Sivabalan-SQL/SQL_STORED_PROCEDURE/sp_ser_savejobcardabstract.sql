Create procedure sp_ser_savejobcardabstract(@JobCardDate DateTime,@AcknowledgementID Int,      
@CustomerID nvarchar(50), @UserName nvarchar(255), @DocRef nVarchar(255) , @Remark nvarchar(255),      
@WhileJobCard int = 1,@BillingAddress nVarchar(1020)=NULL,@ShippingAddress nvarchar(1020)=NULL,    
@ServiceType int= 0,@ClaimType int= 0,@FaultCode nvarchar(255)=NULL, @Apportionated Int = 0, @ChargePerLu Decimal(18,6),@DocumentType varchar(100) = '')            
as            
Declare @DocumentID Int            
Declare @DocSerialType nvarchar(100)            
Declare @Prefix nvarchar(30)      
Declare @LastCount int      
begin tran            
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 101            
 select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 101            
commit tran            
        
if @DocumentType  = ''            
Begin            
 select top 1 @DocumentType = Documenttype from TransactionDocNumber       
 Inner Join DocumentUsers On TransactionDocNumber.serialno = Documentusers.serialno        
 where TransactionType = 101 and TransactionDocNumber.Active = 1       
 and Documentusers.username = @UserName      
 If isnull(@DocumentType, '') = ''       
 begin       
  select top 1 @DocumentType = Documenttype      
  from TransactionDocNumber       
  where TransactionType = 101 and TransactionDocNumber.Active = 1       
 end       
 if isnull(@DocumentType, '') <> '' and @WhileJobCard <> 1       
 begin         
  BEGIN TRAN          
   UPDATE TransactionDocNumber SET LastCount = LastCount + 1         
   WHERE TransactionType = 101 And DocumentType=@DocumentType          
   SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber       
   WHERE TransactionType = 101 And DocumentType=@DocumentType       
  COMMIT TRAN      
  set @DocRef = dbo.fn_ser_GetTransactionSerial(101, @DocumentType, @LastCount)       
      
 end       
      
 if isnull(@DocRef, '') = ''      
 begin       
  select @Prefix = Prefix from VoucherPrefix where [TranID]= 'JOBCARD'      
  Set @DocRef = isnull(@Prefix, 'JC') + Cast(@DocumentID as nvarchar(20))      
 end      
End            
     
set @DocSerialType = isnull(@DocumentType, '')      
    
Insert JobCardAbstract(JobCardDate, DocumentID, AcknowledgementID, CustomerID, UserName, DocRef,       
Remarks, DocSerialType,BillingAddress,ShippingAddress,ServiceType,ClaimType,FaultCode,ApportionApplied,ChargePerLabourUnit)      
Values(@JobCardDate, @DocumentID, @AcknowledgementID, @CustomerID, @UserName, @DocRef,       
@Remark, @DocSerialType,@BillingAddress,@ShippingAddress,@ServiceType,@ClaimType,@Faultcode, @Apportionated, @ChargePerLu)            
            
Select @@Identity,@DocumentID       
