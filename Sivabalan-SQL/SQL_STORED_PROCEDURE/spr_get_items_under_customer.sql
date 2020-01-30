
CREATE PROC spr_get_items_under_customer
		( @CustomerID nVarchar(15) ,
		  @CategoryID int,
		  @BeatId int,	
		  @FromDate Datetime,
  		  @ToDate Datetime
		)
AS
DECLARE @InvoiceId int
SELECT InvoiceDetail.Product_Code, Items.ProductName, sum(InvoiceDetail.Quantity), sum(InvoiceDetail.Amount)
	from InvoiceDetail, Items , Itemcategories, InvoiceAbstract
	where InvoiceAbstract.InvoiceId = InvoiceDetail.InvoiceID and
	InvoiceAbstract.CustomerID = @CustomerID and
	InvoiceAbstract.BeatID = @BeatID and
	InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and
	Items.Product_Code = InvoiceDetail.Product_Code	 and
	Items.CategoryID = Itemcategories.CategoryID AND
	Items.CategoryID = @CategoryID and 
	InvoiceAbstract.InvoiceType in (1,3) and
	(InvoiceAbstract.Status & 128) = 0
	GROUP BY InvoiceDetail.Product_Code, Items.ProductName

