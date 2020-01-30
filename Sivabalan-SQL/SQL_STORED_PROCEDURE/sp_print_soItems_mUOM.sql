CREATE  PROCEDURE sp_print_soItems_mUOM (@SONumber int)      
AS      

SELECT "Item Code" = Max(SODetail.Product_Code), "Item Name" = Max(ProductName),   
 "Quantity" = (Case When Count(SODETAIL.Serial) > 1 then dbo.GetQtyAsMultiple(Max(SODetail.Product_Code), sum(quantity)) 
		else cast(sum(UOMQTY)as nvarchar) End),
 "Sale Price" = (Case When Count(SODETAIL.Serial) > 1 then Max(SalePrice) Else Sum(UOMPRICE)END),
 "Tax" = ISNULL(max(SaleTax), 0) + ISNULL(max(TaxCode2), 0),      
 "Discount" = avg(Discount),
 "UOM" = (Case When Count(SODETAIL.Serial) > 1 then 'Multiple' Else 
	dbo.fn_GetUOMDesc(Sum(SoDetail.UOM),0) End),
 "Pending" =dbo.GetQtyAsMultiple(Max(SODetail.Product_Code),sum(isnull(Pending,0))),        
 "Tax Suffered" = ISNULL(max(SODetail.TaxSuffered), 0),
 "Description" = MAX(Items.Description),          
 "Item Gross Value" = Sum(quantity * SalePrice),
 "Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, Max(SODetail.Product_Code)),0),
 "Total Tax Amount"=Round(
							Sum(
									(
										(
											(SODetail.Quantity * SODetail.SalePrice) - 
											(
												(SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100
											)
										)*
										(
											IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0)
										)/100
									)
								)
							,2),
"Batch" = MAX(SODetail.Batch_Number),
"UOM"=Case When Count(SODETAIL.Serial) > 1 then 0 else Sum(SoDetail.UOM) End,
"PriceOption" = mAX(ItemCategories.Price_Option),"TrackBatch"= mAX(Items.Track_Batches),
"OriginalSalePrice"=mAX(Sodetail.SalePrice),
"VAT" = mAX(isnull(sodetail.vat,0)),
"TaxApplicableon" = MAX(isnull(sodetail.taxapplicableon,0)),
"TaxPartOff" = mAX(isnull(sodetail.taxpartoff,0)),
"TaxSuffApplicableon" = mAX(isnull(sodetail.taxSuffapplicableon,0)),
"TaxsuffPartOff" = mAX(isnull(sodetail.taxsuffpartoff,0))
FROM SODetail, Items,ItemCategories
WHERE SODetail.SONumber = @SONumber       
AND SODetail.Product_Code = Items.Product_Code       
And Items.CategoryID = ItemCategories.CategoryID
group by Sodetail.Serial
order by Sodetail.Serial
















