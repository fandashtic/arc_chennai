CREATE PROCEDURE [dbo].[sp_get_InvDetails_FMCG](@CustomerID NVARCHAR(15), @Inv_No INT)      
AS      
 
SELECT GrossValue, DiscountPercentage, DiscountValue, NetValue,       
AdditionalDiscount, Freight, NewReference, CreditTerm, ReferenceNumber, Memo1,      
Memo2, Memo3, PaymentDate, PaymentMode, DocReference, InvoiceDate, IsNull(SalesmanID,0),      
IsNull(AdjustmentValue, 0),Balance,PaymentDetails,"DocumentType" =DocSerialType,
SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount, Status  
FROM InvoiceAbstract      
WHERE InvoiceID = @Inv_No      
       
SELECT Company_Name, BillingAddress, ShippingAddress FROM Customer      
WHERE CustomerID = @CustomerID      

SELECT InvDt.Product_Code AS "ProductCode", ProductName, MIN(InvDt.Batch_Code),   
InvDt.Batch_Number, SUM(InvDt.Quantity), IsNull(InvDt.SalePrice,0), Price_Option,  
IsNull(MAX(InvDt.TaxCode), 0), SUM(InvDt.DiscountPercentage), SUM(InvDt.DiscountValue), 
SUM(InvDt.Amount), Track_Batches, ItemCategories.Track_Inventory , InvDt.SaleID,   
IsNull(MAX(InvDt.TaxCode2), 0), IsNull(MAX(InvDt.TaxSuffered), 0), IsNull(MAX(TaxSuffered2), 0), 
IsNull(BP.Free,0), 
BP.SALEPRICE,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, InvDt.SCHEMEDISCPERCENT, InvDt.SCHEMEDISCAMOUNT, InvDt.SPLCATDISCPERCENT, InvDt.SPLCATDISCAMOUNT,
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SchemeID),0) SCHEME_INDICATOR,
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR
,"SPBED" = InvDt.SalePriceBeforeExciseAmount, "ExciseDuty" = InvDt.ExciseDuty,
Max(InvDt.TaxSuffApplicableOn) 'TaxSuffApplicableOn', Max(InvDt.TaxSuffPartOff) 'TaxSuffPartOff' ,   
Max(InvDt. TaxApplicableOn) 'TaxApplicableOn', Max(InvDt.TaxPartOff) 'TaxPartOff',
max(stpayable)as Stpayable,max(stcredit) as StCredit,max(taxamount) as TaxAmount,Max(taxsuffamount) as TaxSuffAmount
FROM InvoiceDetail InvDt
Inner Join Items on Items.Product_Code = InvDt.Product_Code
Left Outer Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Right Outer Join Batch_Products BP on BP.Batch_Code = InvDt.Batch_Code
WHERE InvDt.InvoiceID = @Inv_No 
--AND Items.Product_Code = InvDt.Product_Code  
--AND Items.CategoryID *= ItemCategories.CategoryID 
--AND BP.Batch_Code =* InvDt.Batch_Code
group by InvDt.Product_Code, Items.ProductName, InvDt.Batch_Number, 
InvDt.SalePrice, InvDt.SaleID, Items.Track_Batches, ItemCategories.Price_Option, 
ItemCategories.Track_Inventory, Isnull(BP.Free,0), 
BP.SALEPRICE,InvDt.Serial,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, InvDt.SCHEMEDISCPERCENT, InvDt.SCHEMEDISCAMOUNT, InvDt.SPLCATDISCPERCENT, InvDt.SPLCATDISCAMOUNT
,InvDt.SalePriceBeforeExciseAmount, InvDt.ExciseDuty  
Order By InvDt.Serial
