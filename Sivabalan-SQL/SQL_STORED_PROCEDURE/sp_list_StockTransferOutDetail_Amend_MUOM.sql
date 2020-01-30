Create Procedure sp_list_StockTransferOutDetail_Amend_MUOM (@DocSerial int)  
As  
 Select StockTransferOutDetail.Product_Code, Items.ProductName,   
  StockTransferOutDetail.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,  
  StockTransferOutDetail.UOM, rate,  
  --UomQty to taken. Multiple uom conversion no longer required.  
  StockTransferOutDetail.UOMQTY Quantity,Amount, 
  StockTransferOutDetail.MRPFORTAX, isnull(StockTransferOutDetail.TaxType,0) TaxType,   
  StockTransferOutDetail.TaxSuffered, StockTransferOutDetail.TaxAmount,   
  stockTransferOutDetail.TotalAmount, ItemCategories.Track_Inventory,  
  ItemCategories.Price_Option, Items.Virtual_Track_Batches,  
  Case Rate  
   When 0 Then  
    1  
   Else  
    0  
  End,  
  Items.TrackPKD, StockTransferOutDetail.PTS, StockTransferOutDetail.PTR,   
  StockTransferOutDetail.ECP, StockTransferOutDetail.SpecialPrice,  
  StockTransferOutDetail.Serial "Serial", StockTransferOutDetail.SchemeID "SchemeID", StockTransferOutDetail.FreeSerial "FreeSerial", StockTransferOutDetail.SchemeFree "SchemeFree",  
  StockTransferOutDetail.TaxSuffApplicableOn,StockTransferOutDetail.TaxSuffPartOff,    
  StockTransferOutDetail.VAT,StockTransferOutDetail.uomprice, StockTransferOutDetail.PFM 
  ,StockTransferOutDetail.MRPperPack,isnull(StockTransferOutDetail.TOQ,0) as TOQ
  ,isnull(StockTransferOutDetail.TaxID,0) as TaxID
  ,isnull(StockTransferOutDetail.GSTTaxType,0) GSTTaxType
  From StockTransferOutDetail
  Inner Join  Items On StockTransferOutDetail.Product_Code = Items.Product_Code 
  Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID 
  Left Outer Join Batch_Products On StockTransferOutDetail.Batch_Code=Batch_Products.Batch_Code
  Where StockTransferOutDetail.DocSerial = @DocSerial And  
  --When the stock is reduced from multiple batchse the first row only having uomqty  
  --other rows are stored as zero  
  stockTransferOutDetail.UOMQTY > 0   
  Order By StockTransferOutDetail.Serial  
