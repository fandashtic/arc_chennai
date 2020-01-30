CREATE procedure sp_acc_getpayableto(@AccountID Int)
as
Select Payable_To from
Vendors where AccountID = @AccountID 
