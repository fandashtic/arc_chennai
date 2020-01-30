CREATE procedure sp_get_BillItems_UOM(@Bill_ID int) 
As  

Select 
BillDetail.Product_Code as "Code",
I.ProductName as "Name",
Quantity, 
PurchasePrice as "PurchasePrice", 
Amount, 
"TaxSuffered" = BillDetail.TaxSuffered, 
TaxAmount, 
"Discount" = IsNull((Select (Case When IsNull(DiscountOption,0) = 2 
Then (BillDetail.Discount /IsNull((BillDetail.Quantity * BillDetail.PurchasePrice),1)*100) 
Else BillDetail.Discount End) From BillAbstract Where BillID = BillDetail.BillID),0),
BillDetail.Batch As "Batch", 
BillDetail.Expiry As "Expiry", 
BillDetail.PKD As "PKD",   
(BillDetail.PTS * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "PTS",   
(BillDetail.PTR * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "PTR",  
(BillDetail.ECP * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "ECP",  
(BillDetail.PFM * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "PFM",  
(BillDetail.SpecialPrice * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "SplPrice",  
"UOMID" = BillDetail.UOM,   
"UOMDescription" = UOM.Description, 
"UOMQty" = Case When PurchasePrice = 0 then 0 Else BillDetail.UOMQty End, 
BillDetail.UOMPrice, 
BillDetail.TaxCode "TaxCode",  
"ExciseDuty" = IsNull(BillDetail.ExciseDuty,0),
"PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0) ,
"Promotion" = isnull(billdetail.promotion,0), 
"PromotionECP" = 
Case IsNull(Promotion,0) When 1 Then BillDetail.ECP Else
(BillDetail.ECP * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) End,
"UOMFreeQty" = Case When PurchasePrice = 0 then BillDetail.UOMQty Else 0 End, 
"DiscPerUnit" = IsNull(DiscPerUnit,0),
"InvDiscPer" = IsNull(InvDiscPerc,0),
"InvDiscPerUnit" = IsNull(InvDiscAmtPerUnit,0),
"InvDiscAmt" = IsNull(InvDiscAmount,0),
"OtherDiscPer" = IsNull(OtherDiscPerc,0),
"OtherDiscPerUnit" = IsNull(OtherDiscAmtPerUnit,0),
"OtherDiscAmt" = IsNull(OtherDiscAmount,0),
"DiscType" = IsNull(DISCTYPE,0),
--(BillDetail.PurchasePrice * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "UOMPTS"
(BillDetail.OrgPTS * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) As "UOMPTS",
"VAT" = IsNull(I.VAT,0),
"PriceOption" = ICA.Price_Option,
"TrackBatch" = I.Virtual_Track_Batches,
"TrackPKD" = I.TrackPKD,
"MRPForTax" = 
	Case When BillDetail.UOM = I.UOM1 then MRPForTax * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End
		When BillDetail.UOM = I.UOM2 then MRPForTax * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End
		Else MRPForTax End
, "MRPPerPack" = BillDetail.MRPPerPack
,"TOQ" = BillDetail.TOQ
,"HSNNumber" = BillDetail.HSNNumber
,"CS_TaxCode" = BillDetail.CS_TaxCode
From BillDetail
inner join Items I on BillDetail.Product_Code = I.Product_Code  
left outer join UOM  on BillDetail.UOM = UOM.UOM  
inner join ItemCategories ICA on  I.CategoryID = ICA.CategoryID
Where  BillID = @Bill_ID    
Order By BillDetail.Serial
