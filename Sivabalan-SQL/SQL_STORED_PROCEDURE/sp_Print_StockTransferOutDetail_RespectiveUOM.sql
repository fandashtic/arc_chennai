Create Procedure sp_Print_StockTransferOutDetail_RespectiveUOM (@DocSerial int)        
As        
BEGIN
	Select "Item Code" = StockTransferOutDetail.Product_Code,         
	"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetail.Batch_Number,         
	"PKD" = Batch_Products.PKD, "Expiry" = Batch_Products.Expiry,        
	"Rate" = Case StockTransferOutDetail.UOMPrice        
	When 0 then        
	'Free'        
	Else        
	Cast(StockTransferOutDetail.UOMPrice as nvarchar)        
	End,         
	"Quantity" = StockTransferOutDetail.UOMQty,      
	"UOM" = UOM.Description,       
	"Amount" = Amount,       
	"PTS" = Batch_Products.PTS,       
	"PTR" = Batch_Products.PTR,         
	"ECP" = Batch_Products.ECP  ,      
	"Special Price" = Batch_Products.Company_Price  ,      
	"Tax Suffered" = IsNull(StockTransferOutDetail.TaxSuffered, 0),        
	"Tax Amount" = IsNull(StockTransferOutDetail.TaxAmount, 0),        
	"Total Amount" = IsNull(StockTransferOutDetail.TotalAmount, 0),
	"PFM" = IsNull(StockTransferOutDetail.PFM, 0)
	From StockTransferOutDetail
	Inner Join Items On StockTransferOutDetail.Product_Code = Items.Product_Code 
	Left Outer Join Batch_Products On StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code
	Left Outer Join UOM On StockTransferOutDetail.UOM = UOM.UOM
	Where  
	StockTransferOutDetail.DocSerial = @DocSerial  And      
	StockTransferOutDetail.UOMQty > 0          
	Order by StockTransferOutDetail.Product_Code      
End
