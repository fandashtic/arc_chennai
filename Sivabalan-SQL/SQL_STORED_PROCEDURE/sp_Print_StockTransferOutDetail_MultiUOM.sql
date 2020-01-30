Create Procedure sp_Print_StockTransferOutDetail_MultiUOM (@DocSerial int)      
As      
BEGIN
	Select "Item Code" = StockTransferOutDetail.Product_Code,       
	"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetail.Batch_Number,       
	"PKD" = Max(Batch_Products.PKD), "Expiry" = Max(Batch_Products.Expiry),      
	"Rate" = Case Sum(Rate)      
	When 0 then      
	'Free'      
	Else      
	Cast(Sum(Rate) as nvarchar)      
	End,       
	"UOM2Quantity" = dbo.GetFirstLevelUOMQty(StockTransferOutDetail.Product_Code, Sum(StockTransferOutDetail.Quantity)),        
	"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  StockTransferOutDetail.Product_Code )),        
	"UOM1Quantity" = dbo.GetSecondLevelUOMQty(StockTransferOutDetail.Product_Code, Sum(StockTransferOutDetail.Quantity)),        
	"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  StockTransferOutDetail.Product_Code )),        
	"UOMQuantity" = dbo.GetLastLevelUOMQty(StockTransferOutDetail.Product_Code, Sum(StockTransferOutDetail.Quantity)),        
	"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  StockTransferOutDetail.Product_Code )),        
	"Amount" = Sum(Amount),       
	"PTS" = Max(Batch_Products.PTS),      
	"PTR" = Max(Batch_Products.PTR),       
	"ECP" = Max(Batch_Products.ECP),      
	"Special Price" = Max(Batch_Products.Company_Price)  ,      
	"Tax Suffered" = IsNull(Sum(StockTransferOutDetail.TaxSuffered), 0),      
	"Tax Amount" = IsNull(Sum(StockTransferOutDetail.TaxAmount), 0),      
	"Total Amount" = IsNull(Sum(StockTransferOutDetail.TotalAmount), 0),
	"PFM" = IsNull(Sum(StockTransferOutDetail.PFM), 0)  
	From StockTransferOutDetail
	Inner Join Items On StockTransferOutDetail.Product_Code = Items.Product_Code 
	Left Outer Join Batch_Products On StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code 
	Where StockTransferOutDetail.DocSerial = @DocSerial      
	Group By StockTransferOutDetail.Product_Code, Items.ProductName,      
	StockTransferOutDetail.Batch_Number  
	--, Batch_Products.Expiry, Batch_Products.PKD,      
	--Batch_Products.Company_Price,StockTransferOutDetail.Rate    
	Order By StockTransferOutDetail.Product_Code    
End
