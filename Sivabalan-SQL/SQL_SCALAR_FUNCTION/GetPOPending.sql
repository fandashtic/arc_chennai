Create Function GetPOPending (@ItemCode nvarchar(20))
Returns decimal(18,6)
As
Begin
Return (Select Sum(Pending) From PODetail, POAbstract
Where POAbstract.PONumber = PODetail.PONumber 
And POAbstract.Status & 128 = 0
And PODetail.Product_Code = @ItemCode
And PODetail.Pending > 0)
End

