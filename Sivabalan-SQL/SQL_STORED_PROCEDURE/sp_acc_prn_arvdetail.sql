CREATE procedure sp_acc_prn_arvdetail(@DocumentID as int)
as
select Type, AccountID, Amount, Particular,dbo.getaccountname(AccountID),TaxPercentage,TaxAmount from ARVDetail
where DocumentID = @DocumentID
