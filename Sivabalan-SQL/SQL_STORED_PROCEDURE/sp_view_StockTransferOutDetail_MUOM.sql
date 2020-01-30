Create Procedure sp_view_StockTransferOutDetail_MUOM (@DocSerial int)    
As    
 Select StockTransferOutDetail.Product_Code, Items.ProductName,     
  --Multiple qty chaged to orginal uom as in the order  
  Null, Null, Null, "UOM" = StockTransferOutDetail.uom,    
  Rate, StockTransferOutDetail.uomqty Quantity,     
  StockTransferOutDetail.Amount, isnull(StockTransferOutDetail.MRPforTax,0)MRPforTax , isnull(StockTransferOutDetail.TaxType,0) TaxType,  StockTransferOutDetail.TaxSuffered,StockTransferOutDetail.TaxAmount,    
  StockTransferOutDetail.TotalAmount,    
  StockTransferOutDetail.Serial "Serial", StockTransferOutDetail.SchemeID "SchemeID", StockTransferOutDetail.FreeSerial "FreeSerial" , StockTransferOutDetail.SchemeFree "SchemeFree",  
  StockTransferOutDetail.TaxSuffApplicableOn,StockTransferOutDetail.TaxSuffPartOff,StockTransferOutDetail.VAT,  
  StockTransferOutDetail.uomprice,StockTransferOutDetail.PFM,isnull(StockTransferOutDetail.TOQ,0) as TOQ
  ,isnull(StockTransferOutDetail.TaxID,0) as TaxID
  ,isnull(StockTransferOutDetail.GSTTaxType,0) GSTTaxType
  From StockTransferOutDetail, Items    
  Where StockTransferOutDetail.Product_Code = Items.Product_Code And    
  StockTransferOutDetail.DocSerial = @DocSerial  and  
  --Elimante the rows which was updated from multiple batches  
  StockTransferOutDetail.uomqty > 0  
  order by serial    
