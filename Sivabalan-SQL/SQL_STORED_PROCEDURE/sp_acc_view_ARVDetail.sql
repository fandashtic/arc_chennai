CREATE procedure sp_acc_view_ARVDetail(@DocumentID as int)
as
select Type, AccountID, Amount, Particular,dbo.getaccountname(AccountID),TaxPercentage,TaxAmount,ServiceChargeAmount from ARVDetail
where DocumentID = @DocumentID

