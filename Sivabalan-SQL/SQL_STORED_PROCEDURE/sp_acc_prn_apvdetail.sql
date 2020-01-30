
CREATE procedure sp_acc_prn_apvdetail(@apvid integer)
as
declare @prefix nvarchar(10)
select @prefix =Prefix from VoucherPrefix
where TranID =N'ACCOUNTS PAYABLE VOUCHER'
select APVDate,'APVID'= @prefix + cast(APVID as nvarchar(10)),BillNo,BillDate,BillAmount,'PartyName'=dbo.getaccountname(PartyAccountID),
PartyAccountID,AmountApproved,'Other Account' = dbo.getaccountname(isnull(OtherAccountID,0)),OtherAccountID,
'OtherValue'= isnull(OtherValue,0),'Expense For Account'= dbo.getaccountname(isnull(Expensefor,0)),
Expensefor,'Approved By Account'=dbo.getaccountname(isnull(Approvedby,0)),'Approvedby'=isnull(Approvedby,0),
APVRemarks,Type,'Detail Account'= dbo.getaccountname(isnull([APVDetail].[AccountID],0)),
'APVDetail AccountID'= AccountID,Amount,Particular
from APVAbstract,APVDetail where [APVAbstract].[DocumentID]= @apvid and
[APVAbstract].[DocumentID]=[APVDetail].[DocumentID]
 
 





