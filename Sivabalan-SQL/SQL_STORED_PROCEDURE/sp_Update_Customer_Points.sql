CREATE Procedure sp_Update_Customer_Points
As
Declare @DocumentNumber nvarchar(250)
Declare @CompanyForumCode nvarchar(20)
Declare @CustomerID nvarchar(30)
Declare @AccumulatedPoints Int
Declare @RedeemedPoints Int

Declare CustPoint Cursor For Select CustomerSalesSummaryAbstract.DocumentNumber,Customer.CustomerID,CustomerSalesSummaryDetail.AccumulatedPoints,CustomerSalesSummaryDetail.RedeemedPoints
					From CustomerSalesSummaryAbstract,CustomerSalesSummaryDetail,Customer
					Where CustomerSalesSummaryAbstract.Status & 0 = 0 and
					CustomerSalesSummaryAbstract.SerialNo=CustomerSalesSummaryDetail.SerialNo and
					CustomerSalesSummaryDetail.CustomerID=Customer.CustomerID
Open CustPoint
Fetch From CustPoint Into @DocumentNumber,@CustomerID,@AccumulatedPoints,@RedeemedPoints
While @@Fetch_Status=0
Begin
	Update Customer Set TrackPoints=1, CollectedPoints=@AccumulatedPoints,
	RedeemedPoints=@RedeemedPoints Where Customer.CustomerID=@CustomerID
	Fetch Next From CustPoint Into @DocumentNumber,@CustomerID,@AccumulatedPoints,@RedeemedPoints
End
Update CustomerSalesSummaryAbstract set Status =Status | 1 
Where DocumentNumber=@DocumentNumber

Close CustPoint
Deallocate CustPoint



