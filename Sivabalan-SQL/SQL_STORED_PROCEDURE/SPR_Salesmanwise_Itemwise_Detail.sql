CREATE Procedure SPR_Salesmanwise_Itemwise_Detail
(@Id nvarchar(255),
@FromDate DateTime,
@ToDate DateTime)
As

declare @SalesmanId Int
Declare @BeatId int

CReate table #tempTab(
ID integer identity(1,1),
NameDesc integer
)

Insert into #temptab(namedesc)
	Select * from dbo.sp_SplitIn2Rows(@Id,':')



-- Set @SalesmanId=Substring(@Id,1,charindex(':',@Id,1)-1)
-- Set @BeatId=Substring(@Id,charindex(':',@Id,1)+1,len(@Id)-1)
Select @Salesmanid=0,@beatid=0

Select @Salesmanid=namedesc from #temptab where id=1
Select @beatid=namedesc from #temptab where id=2

Select  
InvoiceDetail.Product_Code as "ItemCode"
,InvoiceDetail.Product_Code as "ItemCode"
,Items.ProductName as "Item Name"
,Manufacturer.Manufacturer_Name as "Manufacturer"
,InvoiceDetail.Batch_Number as "Batch"
,InvoiceDetail.SalePrice
,InvoiceDetail.Quantity
,(Case InvoiceType When 4 then 0-InvoiceDetail.Amount Else InvoiceDetail.Amount End) as "Amount"
from InvoiceAbstract,InvoiceDetail,Items,manufacturer
Where
	InvoiceAbstract.InvoiceId=InvoiceDetail.InvoiceId And
	Items.Product_Code=InvoiceDetail.Product_Code	And
	manufacturer.manufacturerId=Items.manufacturerId And
	InvoiceAbstract.Invoicedate between @FromDate And @Todate
	And InvoiceAbstract.Invoicetype in (1,3,4)
	And InvoiceAbstract.Status & 128=0 And
	ISnull(InvoiceAbstract.SalesmanId,0)=@SalesManid And
	Isnull(InvoiceAbstract.BeatId,0) =@BeatId 	

Drop table #temptab




