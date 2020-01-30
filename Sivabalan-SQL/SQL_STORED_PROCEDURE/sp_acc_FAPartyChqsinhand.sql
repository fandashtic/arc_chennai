CREATE Procedure sp_acc_FAPartyChqsinhand(@AccountID Int)
As

Select IsNull(Sum(value),0) from Collections where 
((Select IsNull(AccountID,0) from Customer where Customer.Customerid=Collections.CustomerID)=@AccountID
 or IsNull(Others,0)=@AccountID) and PaymentMode in (1, 2) and IsNull(DepositID, 0) = 0 and 
(IsNull(Status, 0) & 192) = 0
