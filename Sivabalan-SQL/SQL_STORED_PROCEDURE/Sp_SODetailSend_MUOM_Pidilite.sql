CREATE PROCEDURE Sp_SODetailSend_MUOM_Pidilite(@DOCTYPE as nvarchar(20),@CID as int)                  
AS                  
IF @DOCTYPE = N'SO'                 
/*	Store UOMDescription,UOM,UOMQty & UOMPrice values into 
	Custom12,Custom13,Custom14 & Custom15 respectively
*/	 
SELECT                 
 "POId" = N'PO1',        
 "POItemNumber" = Serial,        
 "ItemId" =isnull((SELECT Alias FROM Items WHERE Product_Code = Sodetail.Product_code),Sodetail.Product_code),        
 "ItemName" = (SELECT ProductName FROM Items WHERE Product_Code = Sodetail.Product_code),        
 "ItemDesc" = (SELECT replace(description,'''','') FROM Items WHERE Product_Code = Sodetail.Product_code),        
 "ItemQty" = IsNull(Quantity,0),        
 "ItemRate" = IsNull(SalePrice,0),        
 "StorageLocation" = N'',        
 "ReqDate" = N'',        
 "ReqTime" = N'',    
 "TaxableFlag" = N'1',        
 "DutyTaxId" = N'TNGST',        
 "DutyTaxRate" = isnull(saletax,0) + Isnull(TaxCode2,0),        
 "Batch" = N'',        
 "Plant" = N'',        
 "ItemCategory" = N'',        
 "MaterialGroup" = N'',        
 "Custom1" = Isnull(Discount,0),        
 "Custom2" = N'',        
 "Custom3" = N'',        
 "Custom4" = N'',        
 "Custom5" = N'',        
 "Custom6" = N'',        
 "Custom7" = N'',        
 "Custom8" = N'',        
 "Custom9" = N'',        
 "Custom10" = N'',        
 "Custom11" = N'',        
 "Custom12" = (Select Description From UOM Where UOM=SODetail.UOM),
 "Custom13" = UOM,     
 "Custom14" = UOMQty,     
 "Custom15" = UOMPrice,     
 "TaxSuffered" =  Isnull(TaxSuffered,0),        
 "TaxSuffApplicableOn" = Isnull(TaxSuffApplicableOn,0),        
 "TaxSuffPartOff" = Isnull(TaxSuffPartOff,0),        
 "TaxApplicableOn" = Isnull(TaxApplicableOn,0),        
 "TaxPartOff" = Isnull(TaxPartOff,0),        
 "Serial" = Isnull(Serial,0)        
FROM SODetail        
WHERE SONumber = @Cid        
