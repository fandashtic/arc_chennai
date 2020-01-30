CREATE procedure sp_insert_Payments(@DocumentDate datetime,  
     @Value Decimal(18,6),  
     @Balance Decimal(18,6),  
     @PaymentMode integer,  
     @ChequeNumber integer,  
     @ChequeDate datetime,  
     @BankID integer,  
     @VendorID nvarchar(15),  
     @DocPrefix nvarchar(50),  
     @ChequeID integer,  
     @BankCode nvarchar(50),  
     @BranchCode nvarchar(50),  
     @DDMode Int = 0,  
     @DDCharges Decimal(18,6) = 0,  
     @DDPayable nvarchar(255) = N'',  
     @DDChqNo Int = 0,  
     @DDChqDate Datetime = NULL,  
     @PayableTo nvarchar(255) = N'',  
     @FlagAmendment Int = 0,  
     @AmendmentID nvarchar(50) = N'',  
     @Bank_Txn_code nvarchar(400) = N'',
     @UserName nvarchar(100) = N'')  
as  
Declare @DocID nvarchar(50)  
  
If @FlagAmendment = 0  
Begin  
 Begin Tran  
 select @DocID = DocumentID from DocumentNumbers where Doctype = 13  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 13  
 Commit Tran  
   
 SET @DocID = @DocPrefix + @DocID  
End  
Else  
Begin  
 Set @DocID = @AmendmentID  
End  
  
if @PaymentMode = 1 and @ChequeID <> 0  
update Cheques set LastIssued = @ChequeNumber, UsedCheques = Isnull(UsedCheques, 0) + 1  
where ChequeID = @ChequeID  
Else If @PaymentMode = 2 And @ChequeID <> 0  
update Cheques set LastIssued = @DDChqNo, UsedCheques = Isnull(UsedCheques, 0) + 1  
where ChequeID = @ChequeID  
  
insert into Payments( FullDocID,  
   DocumentDate,  
   Value,  
   Balance,  
   PaymentMode,  
   Cheque_Number,  
   Cheque_Date,  
   BankID,  
   VendorID,  
   Cheque_ID,  
   BankCode,  
   BranchCode,  
   DDMode,  
   DDCharges,  
   DDChequeNumber,  
   DDChequeDate,  
   DDDetails,  
   PayableTo,  
   Memo,UserName)  
values  
         (@DocID,  
   @DocumentDate,  
   @Value,  
   @Balance,  
   @PaymentMode,  
   @ChequeNumber,  
   @ChequeDate,  
   @BankID,  
   @VendorID,  
   @ChequeID,  
   @BankCode,  
   @BranchCode,  
   @DDMode,  
   @DDCharges,  
   @DDChqNo,  
   @DDChqDate,  
   @DDPayable,  
   @PayableTo,  
   @Bank_Txn_code,@UserName)  
  
select @@IDENTITY, @DocID  
