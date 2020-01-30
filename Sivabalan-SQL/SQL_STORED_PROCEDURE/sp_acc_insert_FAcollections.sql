CREATE procedure sp_acc_insert_FAcollections(@DocumentDate datetime,      
     @Value float,      
     @Balance float,      
     @PaymentMode integer,      
     @ChequeNumber integer,      
     @ChequeDate datetime,      
     @Others Int,      
     @ExpenseAccount Int,      
     @DocPrefix nvarchar(50),      
     @BankCode nvarchar(10),      
     @BranchCode nvarchar(10),      
     @Denomination nvarchar(250),      
     @DocRef nvarchar(255),    
   @DocType nVarchar(100),    
   @Narration nVarchar(2000))           
as      
Declare @DocID nvarchar(50)      
      
Begin Tran      
update DocumentNumbers set DocumentID=DocumentID+1 where DocType=57      
Select @DocID=DocumentID-1 from DocumentNumbers where DocType=57      
Commit Tran      
SET @DocID = @DocPrefix + @DocID      
insert into Collections(FullDocID,      
   DocumentDate,      
   Value,      
   Balance,      
   PaymentMode,      
   ChequeNumber,      
   ChequeDate,      
   Others,      
   ExpenseAccount,      
   Denomination,      
   DocReference,      
   BankCode,      
   BranchCode,    
   DocSerialType,    
 Narration)      
values      
         (@DocID,      
   @DocumentDate,      
   @Value,      
   @Balance,      
   @PaymentMode,      
   @ChequeNumber,      
   @ChequeDate,      
   @Others,      
   @ExpenseAccount,      
   @Denomination,      
   @DocRef,      
   @BankCode,      
   @BranchCode,    
   @DocType,    
 @Narration)      
    
select @@IDENTITY, @DocID 
