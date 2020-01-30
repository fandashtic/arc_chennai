CREATE Procedure sp_print_RetInvCategory(@INVNO INT)
As
Select "Category Name" = ItemCategories.Category_Name,
"Quantity" = Sum(InvoiceDetail.Quantity),
"SalePrice" = Max(InvoiceDetail.SalePrice),
"Tax Percentage" = Max(IsNull(InvoiceDetail.TaxCode,0)) + Max(IsNull(InvoiceDetail.TaxCode2,0)),
"Discount Percentage" = Max(InvoiceDetail.DiscountPercentage),
"Discount Value" = Sum(InvoiceDetail.Discountvalue),
"Amount" = Sum(amount),
"Tax Suffered Percentage" = Max(InvoiceDetail.TaxSuffered),
"Tax Applicable Value" = Sum(IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0)),    
"Tax Suffered Value" =ISnull(Sum(InvoiceDetail.Quantity) * Max(InvoiceDetail.SalePrice) * (Max(InvoiceDetail.TaxSuffered)/100),0)
From InvoiceDetail,Itemcategories,Items
Where Items.Product_code=InvoiceDetail.Product_code
And Items.categoryid=Itemcategories.categoryid
And InvoiceDetail.InvoiceID=@INVNO
Group By ItemCategories.Category_Name

