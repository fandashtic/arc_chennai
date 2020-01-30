Create Procedure mERP_spr_DandDRFADetail(@DocID Int)
As
Begin
	Select Itm.Product_Code, Itm.Product_Code as [Item Code], Itm.ProductName as [Item Name],
	IC3.Category_Name as [Category],UOM.Description as [UOM], sum(Isnull(TotalQuantity,0)) as [Total Qty], sum(Isnull(RFAQuantity,0)) as [RFA Qty],
	MAX(Isnull(UOMTaxAmount,0)) as [Tax Amount], max(Isnull(UOMTotalamount,0)) as [Total Amount],
	max(Isnull(SalvageQuantity,0)) as [Salvage Qty], max(Isnull(SalvageRate,0)) as [Salvage Rate], max(Isnull(SalvageValue,0)) as [Salvage Value],
	(max(Isnull(UOMTotalamount,0))- max(Isnull(SalvageValue,0))) as [RFA Value]
	From Items Itm, DandDDetail,ItemCategories IC1, ItemCategories IC2,ItemCategories IC3, UOM
	Where DandDDetail.ID = @DocID
	and DandDDetail.Product_code = Itm.Product_Code
	and Itm.UOM = UOM.Uom
	and Itm.CategoryID = IC1.CategoryID
	and IC1.ParentID = IC2.CategoryID
	and IC2.ParentID = IC3.CategoryID
	Group by Itm.Product_Code,Itm.ProductName,IC3.Category_Name,UOM.Description
	Order by Itm.Product_code
End
