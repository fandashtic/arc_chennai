CREATE Procedure sp_acc_PartyChqsinhand(@CustomerID nVarchar(15))
As

Select IsNull(Sum(value),0) from Collections where CustomerID=@CustomerID and
PaymentMode in (1, 2) and IsNull(DepositID, 0) = 0 and (IsNull(Status, 0) & 192) = 0

