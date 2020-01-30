Create PROCEDURE sp_List_HHSR(@FromDate Datetime, @ToDate Datetime, @CustomerID nvarchar(15) = '', @ReturnType int = 1)  
AS

	Select SR.ReturnNumber, SR.DocumentDate, C.CustomerID, C.Company_Name  
	From Stock_Return SR Inner Join Customer C ON SR.OutletID = C.CustomerID
	Where SR.DocumentDate Between @FromDate and @ToDate 
		and C.CustomerID = @CustomerID and SR.ReturnType = @ReturnType and Processed = 3 and isnull(PendingQty,0) > 0
	Group By SR.ReturnNumber, SR.DocumentDate, C.CustomerID, C.Company_Name

