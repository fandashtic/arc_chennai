CREATE procedure [dbo].[sp_acc_loadpaymentdetail](@paymentid integer,@mode integer)    
as    
Declare @party nvarchar(50)    
Declare @partyid int    
Declare @documentid int    
Declare @documentdate datetime    
Declare @value decimal(18,6)    
Declare @bankid int    
Declare @chequenumber int    
Declare @chequedate datetime    
Declare @bankcode nvarchar(20)    
Declare @branchcode nvarchar(20)    
Declare @denominations nvarchar(2000)    
Declare @chequeid integer    
Declare @chequebookname nvarchar(50)     
Declare @accountno nvarchar(64)    
Declare @APVDocumentID int    
Declare @DocumentType int    
Declare @APVDocumentDate datetime    
Declare @PaymentDate datetime    
Declare @AdjustedAmount decimal(18,6)    
Declare @OriginalID nvarchar(20)    
Declare @DocumentValue decimal(18,6)    
Declare @ExtraCol decimal(18,6)    
Declare @Adjustment decimal(18,6)    
Declare @paymenttype int    
Declare @fulldocid nvarchar(20)    
Declare @paymentmode int    
Declare @expenseaccount nvarchar(50)    
Declare @expenseid int    
Declare @balance decimal(18,6)    
Declare @status int    
Declare @DocumentReference nvarchar(50)    
Declare @Remarks nvarchar(4000)    
Declare @DocType nVarchar(100)    
Declare @DocRef nVarchar(100)    
Declare @Narration nvarchar(2000)    
    
Declare @DDMode Int    
Declare @DDPayableAt nVarChar(128)    
Declare @DDCharges Decimal(18,6)    
Declare @DDChequeDate DateTime    
Declare @DDChequeNo nVarchar(50)    
Declare @PayableTo nVarchar(255)    
Declare @Bank_txn_code nVarchar(400)
/*
If @mode = -1 , then invoked for Show Payments
*/
If @Mode = -1 
Begin
	Select @paymenttype =
	Case
		When Isnull(Others,0) > 0 and isnull(ExpenseAccount,0) = 0 Then 0
		When Isnull(Others,0) > 0 and isnull(ExpenseAccount,0) > 0 Then 1
		When Isnull(Others,0) = 0 and isnull(ExpenseAccount,0) > 0 Then 2
	End
	From Payments where DocumentID = @paymentid
End
Else
Begin
	set @paymenttype = @mode   
End
    
create table #temppayments1(Party nvarchar(50),PartyID int, DocumentID integer,DocumentDate datetime,    
PaymentType int,FullDocID nvarchar(10),PaymentMode integer,ExpenseAccount nvarchar(50),Expenseid int,    
Value decimal(18,6),AccountNo nvarchar(64),ChequeNo integer,ChequeDate datetime,BankCode nvarchar(20),    
BranchCode nvarchar(20),Denominations nvarchar(2000),ChequeID integer,ChequeBookName nvarchar(30),    
APVDocumentID int,DocumentType int,APVDocumentDate datetime,PaymentDate datetime,    
AdjustedAmount decimal(18,6),OriginalID nvarchar(20),DocumentValue decimal(18,6),    
ExtraCol decimal(18,6),Adjustment decimal(18,6),Balance decimal(18,6),Status int,BankID int,    
DocumentReference nvarchar(50),DDMode Int,DDPayableAt nchar(128),DDCharges Decimal(18,6),    
DDChequeDate DateTime,DDChequeNo Integer,Remarks nvarchar(4000),PayableTo nVarchar(255),    
DocType nVarchar(100),DocRef nVarchar(100),Narration nVarchar(2000),Bank_txn_code nVarchar(400))    
    
 declare scanpaymentdetail cursor keyset for    
    
 select dbo.getaccountname(isnull(payments.Others,0)),isnull(Payments.Others,0),    
 Payments.DocumentID,Payments.DocumentDate,Payments.FullDocID,payments.Paymentmode,    
 dbo.getaccountname(isnull(Payments.expenseaccount,0)),Expenseaccount,    
 payments.Value,isnull([Payments].[BankID],0),     
 isnull(Cheque_Number,0),Cheque_Date,isnull([Payments].[BankCode],0),    
 isnull(BranchCode,0),Denominations,isnull(Cheque_ID,0),    
 PaymentDetail.DocumentID,PaymentDetail.documenttype,    
 PaymentDetail.DocumentDate,PaymentDetail.PaymentDate,    
 paymentDetail.AdjustedAmount,PaymentDetail.OriginalID,    
 PaymentDetail.DocumentValue,paymentDetail.ExtraCol,    
 PaymentDetail.Adjustment,dbo.getbalance(PaymentDetail.DocumentID,    
 PaymentDetail.DocumentType),isnull(Payments.Status,0),PaymentDetail.DocumentReference,    
 DDMode,DDDetails,DDCharges,DDChequeDate,DDChequeNumber,Remarks,PayableTo,DocSerialType,DocRef,Narration,Memo    
 from Payments
 Left Join PaymentDetail on Payments.DocumentID = PaymentDetail.PaymentID  
 --Payments,PaymentDetail 
 where Payments.DocumentID = @paymentid 
 --and Payments.DocumentID *= PaymentDetail.PaymentID    
    
 open scanpaymentdetail    
 fetch from scanpaymentdetail into @party,@partyid,@documentid,@documentdate,@fulldocid,    
 @paymentmode,@expenseaccount,@expenseid,@value,@bankid,@chequenumber,@chequedate,    
 @bankcode,@branchcode,@denominations,@chequeid,@APVDocumentID,@documenttype,@apvdocumentdate,    
 @paymentdate,@adjustedamount,@originalid,@documentvalue,@extracol,@adjustment,@balance,@status,    
 @documentreference,@DDMode,@DDPayableAt,@DDCharges,@DDChequeDate,@DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
     
 while @@fetch_status =0    
 begin    
  if @paymentmode = 0    
  begin    
   insert into #temppayments1    
   select @party,@partyid,@documentid,@documentdate,@paymenttype,    
   @fulldocid,@paymentmode,@expenseaccount,@expenseid,@value,0,    
   0,null,0,0,@denominations,0,null,@apvdocumentid,@documenttype,    
   @apvdocumentdate,@paymentdate,@adjustedamount,@originalid,    
   @documentvalue,@extracol,@adjustment,@balance,@status,0,    
   @documentreference,@DDMode,@DDPayableAt,@DDCharges,    
   @DDChequeDate,@DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
  end    
  else if @paymentmode =1     
  begin    
       
   select @accountno = Account_Number from bank where [BankID]= @bankid      
       
   select @chequebookname = Cheque_Book_Name from cheques where chequeid =@chequeid    
       
   insert into #temppayments1    
   select @party,@partyid,@documentid,@documentdate,@paymenttype,    
   @fulldocid,@paymentmode,@expenseaccount,@expenseid,@value,@accountno,    
   @chequenumber,@chequedate,@bankcode,@branchcode,@denominations,@chequeid,    
   @chequebookname,@apvdocumentid,@documenttype,@apvdocumentdate,    
   @paymentdate,@adjustedamount,@originalid,@documentvalue,@extracol,@adjustment,    
   @balance,@status,@bankid,@documentreference,@DDMode,@DDPayableAt,@DDCharges,    
   @DDChequeDate,@DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
      
  end     
  else if @paymentmode =2    
  begin    
   select @accountno = Account_Number from bank where [BankID]= @bankid      
    
   select @chequebookname = Cheque_Book_Name from cheques where chequeid =@chequeid    
    
   insert into #temppayments1     
   select @party,@partyid,@documentid,@documentdate,@paymenttype,    
   @fulldocid,@paymentmode,@expenseaccount,@expenseid,@value,@accountno,    
   @chequenumber,@chequedate,@bankcode,@branchcode,@denominations,@chequeid,    
   @chequebookname,@apvdocumentid,@documenttype,@apvdocumentdate,    
   @paymentdate,@adjustedamount,@originalid,@documentvalue,@extracol,@adjustment,    
   @balance,@status,0,@documentreference,'DD Mode' = @DDMode,    
   'DD PayableAt' = @DDPayableAt,'DDCharges' = @DDCharges,    
   'DDChequeDate' = @DDChequeDate,'DDChequeNo' = @DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
    
  end    
  else if @paymentmode = 4
  begin    
   select @accountno = Account_Number from bank where [BankID]= @bankid      
   
   insert into #temppayments1     
   select @party,@partyid,@documentid,@documentdate,@paymenttype,    
   @fulldocid,@paymentmode,@expenseaccount,@expenseid,@value,@accountno,    
   @chequenumber,@chequedate,@bankcode,@branchcode,@denominations,@chequeid,    
   @chequebookname,@apvdocumentid,@documenttype,@apvdocumentdate,    
   @paymentdate,@adjustedamount,@originalid,@documentvalue,@extracol,@adjustment,    
   @balance,@status,0,@documentreference,@DDMode,@DDPayableAt,@DDCharges,    
   @DDChequeDate,@DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
    
  end    
      
  fetch next from scanpaymentdetail into @party,@partyid,@documentid,@documentdate,@fulldocid,    
  @paymentmode,@expenseaccount,@expenseid,@value,@bankid,@chequenumber,@chequedate,    
  @bankcode,@branchcode,@denominations,@chequeid,@APVDocumentID,@documenttype,@apvdocumentdate,    
  @paymentdate,@adjustedamount,@originalid,@documentvalue,@extracol,@adjustment,@balance,@status,@documentreference,    
  @DDMode,@DDPayableAt,@DDCharges,@DDChequeDate,@DDChequeNo,@Remarks,@PayableTo,@DocType,@DocRef,@Narration,@Bank_txn_code
 end    
 close scanpaymentdetail    
 deallocate scanpaymentdetail    
     
 select * from #temppayments1    
 drop table  #temppayments1 



