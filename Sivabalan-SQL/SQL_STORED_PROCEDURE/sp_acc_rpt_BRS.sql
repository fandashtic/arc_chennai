CREATE procedure sp_acc_rpt_BRS  
(@fromdate Datetime,@todate Datetime,@bankid as integer,@mode as integer)  
as  
Declare @BankACName nvarchar(255)  
Declare @BankName nVarchar(255)  
Declare @BranchName nVarchar(255)  
  
-- -- -- Declare @Fromdate datetime  
-- -- -- Declare @todate datetime  
-- -- -- Declare @Mode int  
  
-- -- -- SELECT * FROM #brsTEMP  
-- -- -- select @fromdate = fromdate,@todate = todate, @mode = mode from #BRSTemp  
Set dateformat dmy  
Select @BankACName = Bank.Account_Number , @BankName=BankMaster.BankName, @BranchName = BranchMaster.BranchName   
From Bank, BankMaster, BranchMaster Where Bank.BankCode = BankMaster.BankCode And  
Bank.BranchCode = BranchMaster.BranchCode And Bank.AccountID = @bANKID  
  
-- -- -- SELECT @FROMDATE,@TODATE,@MODE  
  
Create table #BRSDetail  
(ROWNUM  INT IDENTITY(1,1),  
DocumentDate datetime, DocumentID nvarchar(15),Descp nVarchar(50),  
Particulars nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),DocRef int,DocType int,  
AccountID int,BRSCheck int,Balance nvarchar(50),TranID integer,HighLight int,  
ActualBankDate datetime,ChequeInfo nVarchar(255)  
)  
  
If @Mode = 0  -- All  
Begin  
-- --  Exec sp_acc_BankReconciliationShowAll @fromdate,@todate,@BankId  
 Insert into #BRSDetail (DocumentDate,DocumentID,Descp,Particulars,Debit,Credit,  
 DocRef,DocType,AccountID,BRSCheck,Balance,TranID,HighLight,ActualBankDate,ChequeInfo)  
 Exec sp_acc_BankReconciliationShowAll @fromdate,@todate,@BankId  
End  
Else if @mode = 1  --Uncleared  
Begin  
 Insert into #BRSDetail   
 Exec sp_acc_BankReconciliationShowAll @fromdate,@todate,@BankId  
End  
Else if @mode = 2  -- Reconciled  
Begin  
 Insert into #BRSDetail (DocumentDate,DocumentID,Descp,Particulars,Debit,Credit,  
 DocRef,DocType,AccountID,BRSCheck,TranID,HighLight,ActualBankDate,ChequeInfo)  
 Exec sp_acc_BankReconciliationStatement @fromdate,@todate,@BankId  
End  
  
select   
"Bank Date" = ActualBankDate,  
"Transaction Date" = DocumentDate,  
"Document ID" = DocumentID,  
"DocumentReference" = dbo.sp_acc_GetFlexibleNumber(Docref,Doctype),  
"Description" = Descp,  
"Particulars" = Particulars,  
"Cheque Information" = ChequeInfo,  
"Docref" = Docref,  
"Doctype" = Doctype,  
"Deposits" = Debit,  
"Withdrawals" = Credit,  
"TranID" = TranID,  
"Display" = Highlight  
from #BRSDetail order by rownum  
-- -- exec sp_acc_BankReconciliationStatement 'Apr 20 2004 12:00AM', 'Apr 20 2005 11:59PM', 523  
-- -- "Bank Name" = @BankName,  
-- -- "Branch Name" = @BranchName,  
-- -- "Bank Account" = @BankACName,  
-- -- "Yes/No" =  
-- -- Case when @mode <> 2 then 'Yes/No' else '' end,  
-- -- "BRS Check" =   
-- -- case when @mode <> 2 then  
-- --  case when brscheck = 1 then 'Yes' else 'No' end  
-- -- else '' end, 
