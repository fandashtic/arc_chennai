create procedure spr_list_items_in_free_saleable
(@docserial as integer)
as
select docserial, "Item Code" = conversiondetail.Product_Code,
"Item Name" = Items.ProductName,
"Quantity" = conversiondetail.Quantity,
"Batch" = conversiondetail.Batch,
"PKD" = conversiondetail.PKD,
"Expiry" = conversiondetail.Expiry,
"PTS" = Case IsNull((Select IsNull(ic.Price_Option, 0) from Items it, ItemCategories ic
where it.CategoryID = ic.CategoryID And it.Product_Code = conversiondetail.Product_Code), 0)

When 1 Then conversiondetail.PTS

Else IsNull((Select IsNull(PTS, 0) From Items it Where 
it.Product_Code = conversiondetail.Product_Code), 0)

End,

--conversiondetail.PTS,
"PTR" = Case IsNull((Select IsNull(ic.Price_Option, 0) from Items it, ItemCategories ic
where it.CategoryID = ic.CategoryID And it.Product_Code = conversiondetail.Product_Code), 0)

When 1 Then conversiondetail.PTR

Else IsNull((Select IsNull(PTR, 0) From Items it Where 
it.Product_Code = conversiondetail.Product_Code), 0)

End,

--conversiondetail.PTR,
"ECP" = Case IsNull((Select IsNull(ic.Price_Option, 0) from Items it, ItemCategories ic
where it.CategoryID = ic.CategoryID And it.Product_Code = conversiondetail.Product_Code), 0)

When 1 Then conversiondetail.ECP

Else IsNull((Select IsNull(ECP, 0) From Items it Where 
it.Product_Code = conversiondetail.Product_Code), 0)

End,

--conversiondetail.ECP,
"Special Price" = Case IsNull((Select IsNull(ic.Price_Option, 0) from Items it, ItemCategories ic
where it.CategoryID = ic.CategoryID And it.Product_Code = conversiondetail.Product_Code), 0)

When 1 Then conversiondetail.SpecialPrice

Else IsNull((Select IsNull(Company_Price, 0) From Items it Where 
it.Product_Code = conversiondetail.Product_Code), 0)

End

--conversiondetail.SpecialPrice
from Items,Conversiondetail
where docserial=@docserial and
conversiondetail.product_code=items.product_code

