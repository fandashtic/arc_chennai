CREATE procedure sp_insert_collections(@DocumentDate datetime,  
     @Value Decimal(18,6),  
     @Balance Decimal(18,6),  
     @PaymentMode integer,  
     @ChequeNumber integer,  
     @ChequeDate datetime,  
     @ChequeDetails nvarchar(128),  
     @CustomerID nvarchar(15),  
     @DocPrefix nvarchar(50),  
     @BankCode nvarchar(10),  
     @BranchCode nvarchar(10),  
     @SalesmanID int,  
     @DocReference nvarchar(128) = N'',  
     @AmendmentFlag Int = 0,  
     @AmendmentDocID nvarchar(50) = N'',  
     @OriginalCollection INT = NULL,  
     @BankID int=0,  
     @CardHolder nvarchar(256)=N'',  
     @CreditCardNumber nvarchar(20)=N'',  
     @CustomerServiceCharge decimal(18,6)=0,  
     @ProviderServiceCharge decimal(18,6)=0,  
     @PaymentModeID integer = Null,  
     @Beat Integer = Null,
     @UserName nvarchar(100)=N'')  
  
as  
Declare @DocID nvarchar(50)  
--DECLARE @SalesmanID int  
DECLARE @BeatID int  
  
If @Beat Is Null  
 select @BeatID = ISNULL(BeatID, 0) from Beat_Salesman where CustomerID = @CustomerID  
Else  
 Set @BeatId = @Beat  
  
If @AmendmentFlag = 0  
Begin  
 Begin Tran  
 select @DocID = DocumentID from DocumentNumbers where Doctype = 12  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 12  
 Commit Tran  
 SET @DocID = @DocPrefix + @DocID  
End  
Else  
Begin  
 SET @DocID = @AmendmentDocID  
End  
insert into Collections(FullDocID,  
   DocumentDate,  
   Value,  
   Balance,  
   PaymentMode,  
   ChequeNumber,  
   ChequeDate,  
   ChequeDetails,  
   CustomerID,  
   SalesmanID,  
   BankCode,  
   BranchCode,  
   BeatID,  
   DocReference,  
   OriginalCollection,  
   BankID,  
   CardHolder,  
   CreditCardNumber,  
   CustomerServiceCharge,  
   ProviderServiceCharge,PaymentModeID,UserName)  
values  
     (@DocID,  
   @DocumentDate,  
   @Value,  
   @Balance,  
   @PaymentMode,  
   @ChequeNumber,  
   @ChequeDate,  
   @ChequeDetails,  
   @CustomerID,  
   @SalesmanID,  
   @BankCode,  
   @BranchCode,  
   @BeatID,  
   @DocReference,  
   @OriginalCollection,  
   @BankID,  
   @CardHolder,  
   @CreditCardNumber,  
   @CustomerServiceCharge,  
   @ProviderServiceCharge,  
   @PaymentModeID,@UserName)  
  
  
select @@IDENTITY, @DocID  
