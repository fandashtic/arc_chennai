CREATE procedure sp_acc_loadinternalcontradetail(@contraid int)
as
Declare @prefix nvarchar(20)
select @prefix = Prefix
from VoucherPrefix
Where TranID = N'InternalContra'

select 'DocumentID' = @prefix + cast(max(DocumentID) as nvarchar(20)), 'Contra Date' = Max(ContraDate), 'From User' = Max(FromUser),'To User' = Max(ToUser),  'From Account' = dbo.getaccountname(max(FromAccountID)),
'Remarks'= Max(Remarks), 'To Account' = dbo.getaccountname(ToAccountID),'FromAccountID'= Max(FromAccountID),
'ToAccountID' = Max(ToAccountID),'Amount Transfer'= Max(AmountTransfer),
'PaymentType' = Max(PaymentType),'FromPaymentMode'= dbo.getpaymentmode(max(FromAccountID)),
'ToPaymentMode' = dbo.getpaymentmode(max(ToAccountID))from ContraAbstract,ContraDetail 
where ContraAbstract.ContraID = @contraid and
ContraAbstract.ContraID = ContraDetail.ContraID
Group by FromAccountID,ToAccountID,PaymentType





