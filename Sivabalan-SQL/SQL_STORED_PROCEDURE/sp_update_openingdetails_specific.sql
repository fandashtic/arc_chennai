CREATE PROCEDURE sp_update_openingdetails_specific(@OPENING_DATE datetime, @ITEM_CODE nvarchar(15))  
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
DECLARE @PriceOption Int

If exists(Select * From SysObjects Where xtype = 'U' And Name = 'Batch_Products_Temp')  
 Drop Table Batch_Products_Temp  
Select * Into Batch_Products_Temp From Batch_Products where Product_Code = @ITEM_CODE

if Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')  
 Drop Table VanPending  

Select "Batch_Code" = VanStatementDetail.Batch_Code, "VanQty" = Sum(IsNull(VanStatementDetail.Pending, 0))  
Into VanPending From VanStatementDetail, VanStatementAbstract Where   
VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial And
VanStatementDetail.Product_Code = @ITEM_CODE And
(VanStatementAbstract.Status & 128) = 0   
group by VanStatementDetail.Batch_Code
  
Update Batch_Products_Temp Set Quantity = Batch_Products_Temp.Quantity + VanPending.VanQty
From Batch_Products_Temp, VanPending
WHERE VanPending.Batch_Code=Batch_Products_Temp.Batch_Code

if Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')  
 Drop Table VanPending  

--**************************************************************************************************************************  
--This SQL is commented as it does not add up stocks from same batch  
--**************************************************************************************************************************  
--To Update Van Stock into Batch_Products_Temp
-- Update Batch_Products_Temp Set Quantity = Batch_Products_Temp.Quantity + IsNull(VanStatementDetail.Pending,0) 
-- From Batch_Products_Temp, VanStatementAbstract, VanStatementDetail 
-- WHERE Batch_Products_Temp.Product_Code = @ITEM_CODE AND
-- VanStatementDetail.Batch_Code=Batch_Products_Temp.Batch_Code and 
-- VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND 
-- (VanStatementAbstract.Status & 128) = 0
--**************************************************************************************************************************  

DECLARE GetOpeningDetails CURSOR STATIC FOR  
SELECT Product_Code, SUM(Quantity), SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)),  
(Sum(DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code)) /  
Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1   
	  Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100,  
--Calculation for CST TaxSuffered Percentage
Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=Batch_Products_Temp.Product_Code) = 1
  	  Then (Sum(Case IsNull(Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code) Else 0 End) /  
		  	  Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1     
		     Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100 
	  Else 0 End 
FROM Batch_Products_Temp  
Where Product_Code = @ITEM_CODE  
Group By Product_Code  
  
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
  
 SELECT  @FreeQty = IsNull(SUM(Quantity),0) FROM Batch_Products_Temp    
 WHERE  Product_Code = @Product_Code And ISNULL(PurchasePrice, 0) = 0  

 UPDATE OpeningDetails SET 
 Free_Opening_Quantity = @FreeQty, Free_Saleable_Quantity = @FreeSaleable, 
 Damage_Opening_Quantity = @DamageQty, Damage_Opening_Value = @DamageValue 
 WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE  
 FETCH NEXT FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered  
END  
CLOSE GetOpeningDetails  
DEALLOCATE GetOpeningDetails  

--Drop the temporarly created batch_products table
If exists(Select * From SysObjects Where xtype = 'U' And Name = 'Batch_Products_Temp')  
 Drop Table Batch_Products_Temp  

--Batch_Products Price gets update On Opening Details
select @priceOption = IsNull(ItemCategories.price_option, 0) 
from items, ItemCategories 
where items.CategoryId = ItemCategories.CategoryId 
And items.Product_Code = @Item_Code
If @PriceOption = 0
Begin
	UPDATE Batch_Products SET PTS = Item.PTS,PTR = Item.PTR,Saleprice=Item.Sale_price,ECP=Item.ECP
	from Batch_Products Batch,Items Item
	WHERE Batch.Product_Code = Item.PRODUCT_CODE and Batch.Product_Code = @Item_Code 
	and	Isnull(Batch.[free],0) <> 1
End


