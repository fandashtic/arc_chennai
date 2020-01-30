CREATE procedure sp_ser_saveestimationabstract(@EstimationDate DateTime,          
@CustomerID nvarchar(50),@UserName nvarchar(255), @DocRef nvarchar(255),         
@Remark nvarchar(255), @WhileEstimation int = 1,@DocumentType varchar(100) = '')          
as          
Declare @DocumentID int          
Declare @DocSerialType nvarchar(100)  
Declare @Prefix nvarchar(30) 
Declare @LastCount int
begin tran          
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 100          
	select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 100          
commit tran          

if @WhileEstimation  <> 1      
begin
	set @DocRef = ''
	select top 1 @DocumentType = Documenttype from TransactionDocNumber 
	Inner Join DocumentUsers On TransactionDocNumber.serialno = Documentusers.serialno  
	where TransactionType = 100 and TransactionDocNumber.Active = 1 
	and Documentusers.username = @UserName
	If isnull(@DocumentType, '') = '' 
	begin 
		select top 1 @DocumentType = Documenttype
		from TransactionDocNumber 
		where TransactionType = 100 and TransactionDocNumber.Active = 1 
	end 
	if isnull(@DocumentType, '') <> '' 
	begin  	
		BEGIN TRAN    
			UPDATE TransactionDocNumber SET LastCount = LastCount + 1   
			WHERE TransactionType = 100 And DocumentType=@DocumentType    
			SELECT @LastCount = LastCount - 1 FROM TransactionDocNumber 
			WHERE TransactionType = 100 And DocumentType=@DocumentType 
		COMMIT TRAN
		set @DocRef = dbo.fn_ser_GetTransactionSerial(100, @DocumentType, @LastCount)	
	end 
	if isnull(@DocRef, '') = ''
	begin 
		select @Prefix = Prefix from VoucherPrefix where [TranID]= 'JOBESTIMATION'
		Set @DocRef = isnull(@Prefix, 'JE') + Cast(@DocumentID as nvarchar(20))
	end
	
end     
set @DocSerialType = isnull(@DocumentType, '')

	Insert EstimationAbstract 
	(DocumentID, EstimationDate, CustomerID, UserName, Status, 
	DocRef, remarks, DocSerialType) 
	Values (@DocumentID, @EstimationDate, @CustomerID, @UserName, (1 * @WhileEstimation), 
	@DocRef, @Remark, @DocSerialType)          

Select @@Identity,@DocumentID          


