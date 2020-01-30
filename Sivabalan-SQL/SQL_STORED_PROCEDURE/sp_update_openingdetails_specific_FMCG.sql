CREATE PROCEDURE sp_update_openingdetails_specific_FMCG(@OPENING_DATE datetime, @ITEM_CODE nvarchar(15))  
AS  
DECLARE @Product_Code nvarchar(15)  
DECLARE @OpeningQty Decimal(18,6)  
DECLARE @OpeningValue Decimal(18,6)  
DECLARE @DamageQty Decimal(18,6)  
DECLARE @DamageValue Decimal(18,6)  
DECLARE @FreeQty Decimal(18,6)  
DECLARE @FreeSaleable Decimal(18,6)  
DECLARE @TaxSuffered Decimal(18,6)  
DECLARE @CSTTaxSuffered Decimal(18,6)
DECLARE @PriceOption INT  

If exists(Select * From SysObjects Where xtype = 'U' And Name = 'Batch_Products_Temp')  
 Drop Table Batch_Products_Temp  
Select * Into Batch_Products_Temp From Batch_Products where Product_Code = @ITEM_CODE
  
--To Update Van Stock into Batch_Products_Temp
Update Batch_Products_Temp Set Quantity = Batch_Products_Temp.Quantity + IsNull(VanStatementDetail.Pending,0) 
From Batch_Products_Temp, VanStatementAbstract, VanStatementDetail 
WHERE Batch_Products_Temp.Product_Code = @ITEM_CODE AND
VanStatementDetail.Batch_Code=Batch_Products_Temp.Batch_Code AND 
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND 
(VanStatementAbstract.Status & 128) = 0 

DECLARE GetOpeningDetails CURSOR STATIC FOR  
SELECT BPT.Product_Code, SUM(BPT.Quantity), SUM(ISNULL(BPT.Quantity, 0) * ISNULL(BPT.PurchasePrice, 0)),   
(Sum(Case IsNull(BPT.ApplicableOn,0) 
When 1 then (IsNull(BPT.PurchasePrice,0) * IsNull(BPT.Quantity,0) * (((IsNull(BPT.TaxSuffered,0) * IsNull(BPT.PartOfPercentage,0)) / 100) / 100))      
When 6 then (IsNull(Items.MRP,0) * IsNull(BPT.Quantity,0) * (((IsNull(BPT.TaxSuffered,0) * IsNull(BPT.PartOfPercentage,0)) / 100) / 100))
Else 0
End)/
Case When Sum(IsNull(BPT.Quantity, 0) *  IsNull(BPT.PurchasePrice, 0)) = 0 Then 1   
Else Sum(IsNull(BPT.Quantity, 0) *  IsNull(BPT.PurchasePrice, 0)) End)*100,
--Calculation for CST TaxSuffered Percentage
Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=BPT.Product_Code) = 1
  	  Then (Sum(Case IsNull(BPT.Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt_FMCG(IsNull(BPT.PurchasePrice,0), IsNull(Items.MRP,0), IsNull(BPT.Quantity, 0), IsNull(BPT.TaxSuffered,0), IsNull(BPT.ApplicableOn, 0), IsNull(BPT.PartOfPercentage, 0), BPT.Batch_Code) Else 0 End) /  
		  	  Case When Sum(IsNull(BPT.Quantity, 0) *  IsNull(BPT.PurchasePrice, 0)) = 0 Then 1     
		     Else Sum(IsNull(BPT.Quantity, 0) *  IsNull(BPT.PurchasePrice, 0)) End)*100 
	  Else 0 End   
FROM Batch_Products_Temp BPT,Items 
WHERE Items.Product_Code=BPT.Product_Code and BPT.Product_Code = @ITEM_CODE 
GROUP BY BPT.Product_Code  
OPEN GetOpeningDetails  
  
FETCH FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered  
WHILE @@FETCH_STATUS = 0  
BEGIN  
 UPDATE OpeningDetails SET Opening_Quantity = @OpeningQty, Opening_Value = @OpeningValue, TaxSuffered_Value=@TaxSuffered, CST_TaxSuffered=@CSTTaxSuffered WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE  
 IF @@ROWCOUNT = 0  
 BEGIN  
   INSERT INTO OpeningDetails(Product_Code, Opening_Date, Opening_Quantity,   
   Opening_Value, TaxSuffered_Value, CST_TaxSuffered)  
   VALUES (@Product_Code, @OPENING_DATE, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered)  
 END  

 SELECT  @DamageQty = ISNULL(SUM(Quantity), 0), @DamageValue = SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) FROM Batch_Products_Temp  
 WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) <> 0  
  
 SELECT  @FreeSaleable = ISNULL(SUM(Quantity), 0) FROM Batch_Products_Temp  
 WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) = 0 And ISNULL(PurchasePrice, 0) = 0  

 SELECT  @FreeqTY = ISNULL(SUM(Quantity), 0) FROM Batch_Products_Temp  
 WHERE  Product_Code = @Product_Code And ISNULL(PurchasePrice, 0) = 0  
  
 UPDATE OpeningDetails SET 
 Free_Opening_Quantity = @FreeQty, Free_Saleable_Quantity = @FreeSaleable, 
 Damage_Opening_Quantity = @DamageQty, Damage_Opening_Value = @DamageValue 
 WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE  
 FETCH NEXT FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered  
END  
CLOSE GetOpeningDetails  
DEALLOCATE GetOpeningDetails  

If exists(Select * From SysObjects Where xtype = 'U' And Name = 'Batch_Products_Temp')  
 Drop Table Batch_Products_Temp  

select @priceOption = IsNull(ItemCategories.price_option, 0) 
from items, ItemCategories 
where items.CategoryId = ItemCategories.CategoryId 
And items.Product_Code = @Item_Code
If @PriceOption = 0
Begin
Update Batch_Products set SalePrice = (Select Sale_Price from 
items where Product_code like @Item_Code )Where   
Product_code = @Item_Code And isnull(free,0) <> 1
End
 
