
CREATE Procedure sp_Close_StockRequest (@StkReqNumber int)
As
Declare @Pending Decimal(18,6)

Select @Pending = Sum(Pending) From Stock_Request_Detail 
Where Stock_Req_Number = @StkReqNumber
Group By Stock_Req_Number

If @Pending = 0 
Begin
	Update Stock_Request_Abstract Set Status = IsNull(Status, 1) | 128 
	Where Stock_Req_Number = @StkReqNumber
End

