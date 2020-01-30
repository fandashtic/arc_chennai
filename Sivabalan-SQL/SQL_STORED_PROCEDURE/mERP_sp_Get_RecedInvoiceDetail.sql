CREATE PROCEDURE mERP_sp_Get_RecedInvoiceDetail
(
@RecedInvID Int,
@Mode Int=0,
@GRNDate DateTime = Null
)
AS

If @GRNDate Is Null  
Set @GRNDate = GetDate()  
-- ItemCategories  
Create table #temp (ProdCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Marginpercent Decimal(18,6),MarginDetId Int, PriceOption int)  
Insert Into #temp  
Select Distinct IRDet.Product_Code,isNull(dbo.merp_fn_Get_ProductMargin(IRDet.Product_Code,@GRNDate),0) , isNull(dbo.merp_fn_Get_ProductMarginDetID(IRDet.Product_Code,@GRNDate),0) , 
( Case When IsNull(I.Productname,'') <> '' then ( Select Price_Option from itemCategories ICA where ICA.CategoryID In ( Select I.CategoryID  from items I where Product_code = IRDet.Product_Code)) Else 0 end)  
--IRDET.ItemOrder  
From InvoiceDetailReceived IRDet, ItemCategories ICA, ItemCategories ICB ,Items I  
Where IRDet.InvoiceID = @RecedInvID  
And (IsNull(IRDet.Pending,0) > 0 Or @Mode = 2)  
 And IRDet.Product_Code = I.Product_Code  
And I.CategoryID = ICA.CategoryID  
And ICA.ParentID = ICB.CategoryID 
and IRDet.salePrice >= 0 
Group By IRDet.Product_Code, IRDet.Batch_Number, IRDet.PKD, IRDet.Expiry,  
IRDet.SalePrice, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff,  
I.CategoryID, I.Productname   
--IRDET.ItemOrder  

Select   
"ItemCode" = IRDet.Product_Code,  
"ItemName" = I.ProductName,  
"Batch" = IRDet.Batch_Number,  
"PKD" = IRDet.PKD,  
"Exp" = IRDet.Expiry,  
"SalePrice" = IRDet.SalePrice,  
"PFM"= IRDet.Base_PTS_SP,  
--"PTR" = Max(IRDet.PTR),  
--"ECP" = Max(IRDet.MRP),  
"PTR" = case when IRDet.Product_Code is null Then Max(IRDet.PTR) else Max(I.PTR) * (Case When IsNull(IRDet.UOM,0) = 0 Then 1 Else (Case When IRDet.UOM = Max(I.UOM1) Then Max(IsNull(I.UOM1_Conversion,1)) When IRDet.UOM = Max(I.UOM2) Then Max(IsNull(I.UOM2_Conversion,1)) Else 1 End) End) end,  
"ECP" = case when IRDet.Product_Code is null Then Max(IRDet.MRP) else Max(I.ECP) * (Case When IsNull(IRDet.UOM,0) = 0 Then 1 Else (Case When IRDet.UOM = Max(I.UOM1) Then Max(IsNull(I.UOM1_Conversion,1)) When IRDet.UOM = Max(I.UOM2) Then Max(IsNull(I.UOM2_Conversion,1)) Else 1 End) End) end,  
"UOM" = IRDet.UOM, "UOMDesc" = Max(U.Description),  
"InvQty" = Sum(Case when IRDet.SalePrice = 0 Then 0 Else (Case when IsNull(IRDet.UOM,0) = 0 then IRDet.Quantity Else IRDet.UOMQty End) End),  
"InvFree" = Sum(Case When IRDet.SalePrice = 0 then IRDet.Quantity Else 0 End),  
"PendingQty" = Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Pending End),  
"PendingFree" = Sum(Case When IRDet.SalePrice = 0 Then IRDet.Pending Else 0 End),  
"ProcessedQty" = Sum(Case when IRDet.SalePrice = 0 Then 0 Else IRDet.Quantity End)-Sum(Case When IRDet.SalePrice = 0 Then 0 Else IRDet.Pending End),  
"ProcessedFree" = Sum(Case When IRDet.SalePrice = 0 then IRDet.Quantity Else 0 End)-Sum(Case When IRDet.SalePrice = 0 Then IRDet.Pending Else 0 End),  
"DiscPercentage" = Max(IRDet.DiscountPercentage),  
"DiscPerUnit" = Max(IsNull(IRDet.DiscPerUnit,0)),  
"TaxPercent" = IRDet.TaxCode,  
"TaxApplicOn" =  IRDet.TaxApplicableOn,  
"TaxPartOff" = IRDet.TaxPartOff,  
"ItemPurPrice" = Max(I.Purchase_Price),  
"PriceOption" = IsNull(#temp.PriceOption,0),  
-- Max(IsNull(ICA.Price_Option,0)),  
-- ( Case When IsNull(I.Productname,'') <> '' then ( Select Price_Option from itemCategories ICA where ICA.CategoryID In ( Select I.CategoryID  from items where Product_code = IRDet.Product_Code)) Else 0 end),  
-- Max(IsNull(ICA.Price_Option,0)),  
"TrackBatch" = Max(I.Virtual_Track_Batches),  
"TrackPKD" = Max(I.TrackPKD),  
"VAT" = isnull(Max(I.VAT),1),  
"PTRMargin" = Isnull(#temp.Marginpercent,0),  
"InvDiscPerc" = Max(Isnull(IRDet.InvDiscPerc,0)), 
"InvDiscAmtPerUnit" = Max(Isnull(IRDet.InvDiscAmtPerUnit,0)),
"InvDiscAmount" = Max(Isnull(IRDet.InvDiscAmount,0)),
"OtherDiscPerc" = Max(Isnull(IRDet.OtherDiscPerc,0)),
"OtherDiscAmtPerUnit" = Max(Isnull(IRDet.OtherDiscAmtPerUnit,0)),
"OtherDiscAmount" = Max(Isnull(IRDet.OtherDiscAmount,0)),
"NetPTS" =  Isnull(IRDet.NetPTS,0),
"PTS_Margin" =  Isnull(IRDet.PTS_Margin,0),
"Base_PTS_SP" =  Isnull(IRDet.Base_PTS_SP,0),
"DISCTYPE" =  Isnull(IRDet.DISCTYPE,0),
--IsNull(  
--(Select Percentage From MarginDetail Where MarginID =   
--(Select Max(MarginID) From MarginDetail where CategoryID = Max(ICB.CategoryID) And EffectiveDate In   
--(Select Max(EffectiveDate) from MarginDetail where EffectiveDate <= @GRNDate And CategoryID = Max(IsNull(ICB.CategoryID,0))))  
--And CategoryID = Max(IsNull(ICB.CategoryID,0))),0),  
"ItemOrder" = Min(IRDET.ItemOrder),
"ForumCode"= IRDet.ForumCode,
"MRPForTax" = Max(IRDet.ItemMRP) * (Case When IsNull(IRDet.UOM,0) = 0 Then 1 Else (Case When IRDet.UOM = Max(I.UOM1) Then Max(IsNull(I.UOM1_Conversion,1)) When IRDet.UOM = Max(I.UOM2) Then Max(IsNull(I.UOM2_Conversion,1)) Else 1 End) End)
, "MRPPerPack" = IRDet.MRPPerPack
,"TOQ" = IRDet.TOQ
,"HSNNumber" = Max(IRDet.HSNNumber)
,"CS_TaxCode" = Max(IRDet.CS_TaxCode)
,"MarginDetID" = Isnull(#temp.MarginDetId ,0)
From InvoiceDetailReceived IRDet
Left Outer Join Items I On IRDet.Product_Code = I.Product_Code
Left Outer Join UOM U On IRDet.UOM = U.UOM  
Left Outer Join #temp On IRDet.Product_Code = #temp.ProdCode --, ItemCategories ICA, ItemCategories ICB  
Where IRDet.InvoiceID = @RecedInvID  
And (IsNull(IRDet.Pending,0) > 0 Or @Mode = 2)  
 --And I.CategoryID = ICA.CategoryID  
 --And ICA.ParentID = ICB.CategoryID  
Group By IRDet.Product_Code, I.ProductName, IRDet.Batch_Number, IRDet.PKD, IRDet.Expiry,  
IRDet.SalePrice, IRDet.Base_PTS_SP, IRDet.UOM, IRDet.TaxCode, IRDet.TaxApplicableOn, IRDet.TaxPartOff ,
Isnull(IRDet.NetPTS,0), Isnull(IRDet.PTS_Margin,0), Isnull(IRDet.Base_PTS_SP,0), Isnull(IRDet.DISCTYPE,0),
#temp.PriceOption,  #temp.Marginpercent,IRDet.ForumCode,IRDet.MRPPerPack,TOQ,#temp.MarginDetId
Order By Min(IRDET.ItemOrder)  
  
Drop table #temp  

