Create Procedure mERP_sp_Get_CSQPSFreeItems (@CustomerID as nvarchar(50))
As
Begin

Select SchAbs.SchemeID, SchAbs.Description, SchCusItem.Product_Code, items.ProductName, Sum(SchCusItem.pending) as 'Pending', IsNull(SchCusItem.GroupID,0) 'GroupID', IsNull(SchDet.SlabID,0) 'SlabID', SchDet.SlabType, Sum(IsNull(BP.Quantity,0)) as 'StockQty'
  From tbl_merp_schemeabstract SchAbs
  Inner Join  tbl_merp_schemeslabdetail SchDet On SchAbs.SchemeID = SchDet.SchemeID 
  Inner Join  tbl_merp_schemeFreeSKU FreeSKU On  SchDet.Slabid =  FreeSKU.slabid 
  Inner Join Items On FreeSKU.SKUCode = items.Product_Code 
  Inner Join SchemeCustomerItems SchCusItem On items.Product_Code = SchCusItem.Product_Code  and SchCusItem.SchemeID = SchAbs.SchemeID 
  Left Outer Join  (select Product_code, Sum(Quantity) as 'Quantity' From Batch_Products Where ISNULL(Damage, 0) = 0 and Quantity > 0  Group by Product_code) BP On FreeSKU.SKUCode = BP.Product_Code
  Where IsNull(SchCusItem.GroupID,0) = SchDet.Groupid and 
       IsNull(SchCusItem.SlabID,0) = SchDet.SlabID and 
       SchCusItem.customerid  = @CustomerID and 
       SchCusItem.Pending > 0 
  Group by SchAbs.SchemeID, SchAbs.description, SchCusItem.Product_Code, items.productname, IsNull(SchCusItem.GroupID,0), IsNull(SchDet.SlabID,0), SchDet.SlabType
  Order  by SchAbs.SchemeID, SchCusItem.Product_Code
End
