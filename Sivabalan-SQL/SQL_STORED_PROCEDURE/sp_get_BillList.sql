
CREATE Procedure sp_get_BillList
                (@VENDORID NVARCHAR (15),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME,
				 @ITEMCODE nvarchar(15))
AS
SELECT BillAbstract.BillID, BillDate, DocumentID, InvoiceReference
from BillAbstract, BillDetail
where 	BillAbstract.BillID = BillDetail.BillID and
		VendorID=@VENDORID and 
		BillAbstract.BillDate between @FromDate and @ToDate and 
		(Status & 128)=0 AND
		BillDetail.Product_code = @ITEMCODE
Group By BillAbstract.BillID, BillDate, DocumentID, InvoiceReference
order by BillAbstract.BillID

