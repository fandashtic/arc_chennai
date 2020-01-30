CREATE Function GetSRPending (@ItemCode nvarchar(20))
Returns decimal(18,6)
As
Begin
Return (Select Sum(Pending) From Stock_Request_Abstract, Stock_Request_Detail 
Where Product_Code = @ItemCode And Pending > 0 And
Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number
And Stock_Request_Abstract.Status & 128 = 0)
End

