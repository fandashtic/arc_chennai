CREATE PROCEDURE [dbo].[sp_get_InvDetails_MUOM](@CustomerID NVARCHAR(15), @Inv_No INT)  
AS  
Declare @Customer_Type as Int
Declare @Locality as int
  
SELECT @Customer_Type = CustomerCategory,@locality =locality  FROM Customer WHERE CustomerID = @CustomerID

SELECT GrossValue, DiscountPercentage, DiscountValue, NetValue,   
AdditionalDiscount, Freight, NewReference, CreditTerm, ReferenceNumber, Memo1,  
Memo2, Memo3, PaymentDate, PaymentMode, DocReference, InvoiceDate, IsNull(SalesmanID,0),  
IsNull(AdjustmentValue, 0), Balance, PaymentDetails,TaxOnMRP,"DocumentType" =DocSerialType  ,
SchemeID , SchemeDiscountPercentage , SchemeDiscountAmount , Status,DeliveryStatus,VanNumber,
"BeatID"=IsNull(BeatID,0),"GroupID"=IsNull(GroupID,-1)
FROM InvoiceAbstract  
WHERE InvoiceID = @Inv_No  
   
SELECT Company_Name, BillingAddress, ShippingAddress FROM Customer  
WHERE CustomerID = @CustomerID  	

SELECT InvDt.Product_Code AS "ProductCode", ProductName, MIN(InvDt.Batch_Code),   
InvDt.Batch_Number, SUM(InvDt.UOMQty), IsNull(InvDt.saleprice,0), Price_Option,  
IsNull(MAX(InvDt.TaxCode), 0), SUM(InvDt.DiscountPercentage), SUM(InvDt.DiscountValue), 
SUM(InvDt.Amount), Track_Batches, ItemCategories.Track_Inventory , InvDt.SaleID,   
IsNull(MAX(InvDt.TaxCode2), 0), IsNull(MAX(InvDt.TaxSuffered), 0), IsNull(MAX(TaxSuffered2), 0), 
InvDt.UOM, IsNull(UOM.Description,N''), InvDt.SalePrice, SUM(InvDt.Quantity), 
IsNull(BP.Free,0), 
--Isnull(Case @Customer_Type When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
(Case When Price_Option = 0 And Track_Inventory =0 then
 Isnull(Case @Customer_Type When 1 Then Max(Items.PTS) When 2 Then Max(Items.PTR) ELSE Max(Items.Company_Price )End,0)  
 Else
 Isnull(Case @Customer_Type When 1 Then Max(BP.PTS) When 2 Then Max(BP.PTR) ELSE Max(BP.Company_Price) End,0) End),  
InvDt.MRP,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, SCHEMEDISCPERCENT = IsNull(InvDt.SCHEMEDISCPERCENT,0), SCHEMEDISCAMOUNT = IsNull(Max(InvDt.SCHEMEDISCAMOUNT),0), SPLCATDISCPERCENT = IsNull(InvDt.SPLCATDISCPERCENT,0), SPLCATDISCAMOUNT = IsNull(Max(InvDt.SPLCATDISCAMOUNT),0),
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SchemeID),0) SCHEME_INDICATOR,
isnull((Select SchemeType From Schemes Where SchemeID = InvDt.SPLCATSchemeID),0) SPLCATSCHEME_INDICATOR
,"SPBED" = InvDt.SalePriceBeforeExciseAmount, "ExciseDuty" = InvDt.ExciseDuty, 
"PTS" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.PTS),0) Else ISNULL(Max(BP.PTS), 0) End),
"PTR" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.PTR),0) Else ISNULL(Max(BP.PTR), 0) End),
"ECP" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.ECP),0) Else ISNULL(Max(BP.ECP), 0) End),
"Company_Price" = (Case When Price_Option = 0 And Track_Inventory =0 Then Isnull(Max(Items.Company_Price),0) Else ISNULL(Max(BP.Company_Price), 0) End),
Max(InvDt.TaxSuffApplicableOn) 'TaxSuffApplicableOn', Max(InvDt.TaxSuffPartOff) 'TaxSuffPartOff',  
Max(InvDt. TaxApplicableOn) 'TaxApplicableOn', Max(InvDt.TaxPartOff) 'TaxPartOff' ,
case when @locality = 1 then max(stpayable) else max(cstpayable) end as Stpayable,
max(stcredit) as StCredit,max(taxamount) as TaxAmount,Max(taxsuffamount) as TaxSuffAmount
FROM InvoiceDetail InvDt
Inner Join Items on Items.Product_Code = InvDt.Product_Code
Left Outer Join UOM on InvDt.UOM = UOM.UOM
Left Outer Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Right Outer Join Batch_Products BP on BP.Batch_Code = InvDt.Batch_Code
WHERE InvDt.InvoiceID = @Inv_No 
--AND Items.Product_Code = InvDt.Product_Code  
--And InvDt.UOM *= UOM.UOM AND Items.CategoryID *= ItemCategories.CategoryID  
--AND BP.Batch_Code =* InvDt.Batch_Code
group by InvDt.Product_Code, Items.ProductName, InvDt.Batch_Number, 
InvDt.UOM, UOM.Description, InvDt.UOMPrice, InvDt.SalePrice, 
InvDt.SaleID, Items.Track_Batches, ItemCategories.Price_Option, 
ItemCategories.Track_Inventory, Isnull(BP.Free,0), 
--Isnull(Case @Customer_Type When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
InvDt.MRP,InvDt.Serial,
InvDt.FlagWord, InvDT.freeSerial, InvDt.SPLCATSerial, InvDt.SpecialCategoryScheme, InvDt.SCHEMEID, InvDt.SPLCATSCHEMEID, IsNull(InvDt.SCHEMEDISCPERCENT,0),  IsNull(InvDt.SPLCATDISCPERCENT,0)
,InvDt.SalePriceBeforeExciseAmount, InvDt.ExciseDuty  
ORDER BY InvDt.Serial
