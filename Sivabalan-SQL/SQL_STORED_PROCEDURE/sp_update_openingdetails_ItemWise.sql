Create PROCEDURE sp_update_openingdetails_ItemWise(@OPENING_DATE datetime, @ItemCode nvarchar(100))
AS
DECLARE @Product_Code nVarchar(100)
DECLARE @OpeningQty Decimal(18,6)
DECLARE @OpeningValue Decimal(18,6)
DECLARE @DamageQty Decimal(18,6)
DECLARE @DamageValue Decimal(18,6)
DECLARE @FreeSaleable Decimal(18,6)
DECLARE @FreeQty Decimal(18,6)
DECLARE @TaxSuffered Decimal(18,6)
DECLARE @CSTTaxSuffered Decimal(18,6)
--DECLARE @FPTaxVal Decimal(18,6)

Declare @GSTEnable Int  
Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

--if Opening Details Updated fir the given date exit proc
If Exists(Select * from OpeningDetails Where Opening_Date = @OPENING_DATE And Product_Code = @ItemCode)
	GoTo ExitProc
   
If Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')    
	Drop Table VanPending    
   
Select "Batch_Code" = VanStatementDetail_Copy.Batch_Code, "VanQty" = Sum(IsNull(VanStatementDetail_Copy.Pending, 0))
Into VanPending From VanStatementDetail_Copy, VanStatementAbstract_Copy
Where VanStatementDetail_Copy.Product_Code = @ItemCode
      And VanStatementAbstract_Copy.Status & 128 = 0
      And VanStatementAbstract_Copy.DocSerial = VanStatementDetail_Copy.DocSerial
Group By VanStatementDetail_Copy.Batch_Code
    
--To Update Van Stock into Batch_Products    
Update Batch_Products_Copy Set Quantity = Batch_Products_Copy.Quantity + VanPending.VanQty
From Batch_Products_Copy, VanPending     
Where Batch_Products_Copy.Product_Code = @ItemCode 	   
      and Batch_Products_Copy.Batch_code = VanPending.Batch_Code    
  
If Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')    
 Drop Table VanPending    

--SELECT FirstPointTaxVal=dbo.Fn_openingbal_TaxCompCalc(Product_Code,IsNull(GRNTaxID,0),IsNull(GSTTaxType,0),IsNull(PurchasePrice,0),IsNull(Quantity,0),1,1)
--Into #FirstPointTaxVal FROM Batch_Products_Copy
--Where Batch_Products_Copy.Product_Code = @ItemCode And Quantity > 0 And IsNull(GRNTaxID,0) > 0 And IsNull(GSTTaxType,0) > 0

--Select @FPTaxVal = Sum(IsNull(FirstPointTaxVal,0)) From #FirstPointTaxVal

--Drop Table #FirstPointTaxVal

SELECT @Product_Code = Product_Code, 
       @OpeningQty = SUM(Quantity), 
       @OpeningValue = SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) ,--+ IsNull(@FPTaxVal,0) ,
	--@FPTaxVal =  Sum(isnull(dbo.Fn_openingbal_TaxCompCalc(Product_Code,IsNull(GRNTaxID,0),IsNull(GSTTaxType,0),IsNull(PurchasePrice,0),IsNull(Quantity,0),1,1),0)), --GST_Changes
--Calculation : (Sum(TaxSufferedAmt)/Sum(Amt)) * 100      
       @TaxSuffered = (Sum(DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code)) /      
                      Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1         
                      Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100,    
--Calculation for CST TaxSuffered Percentage    
       @CSTTaxSuffered = Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=Batch_Products_Copy.Product_Code) = 1    
            Then (Sum(Case IsNull(Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code) Else 0 End) /      
       Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1         
       Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100     
       Else 0 End     
FROM Batch_Products_Copy
Where Batch_Products_Copy.Product_Code = @ItemCode
GROUP BY Product_Code

INSERT INTO OpeningDetails(Product_Code, Opening_Date, Opening_Quantity, Opening_Value, TaxSuffered_Value, CST_TaxSuffered)
VALUES (@Product_Code, @OPENING_DATE, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered)
--Update Damage Quantity
SELECT  @DamageQty = ISNULL(SUM(Quantity), 0), @DamageValue = SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) 
FROM Batch_Products_Copy
WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) <> 0
--Update Saleable Free Quantity
SELECT  @FreeSaleable = ISNULL(SUM(Quantity), 0) 
FROM Batch_Products_Copy     
WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) = 0 And ISNULL(Free, 0) = 1
--Update Free Quantity
SELECT  @FreeQty = SUM(Quantity) 
FROM Batch_Products_Copy        
WHERE  Product_Code = @Product_Code And IsNull(Free,0) = 1

UPDATE OpeningDetails SET
Free_Opening_Quantity = @FreeQty,
Free_Saleable_Quantity = @FreeSaleable,
Damage_Opening_Quantity = @DamageQty,
Damage_Opening_Value = @DamageValue
WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE        

If @GSTEnable = 1 
Begin
Declare @STaxCode Int
Declare @PTaxCode Int
Declare @NewSTaxCode Int
Declare @NewPTaxCode Int

Select @STaxCode = IsNull(Sale_Tax,0) , @PTaxCode = IsNull(TaxSuffered,0) From Items Where Product_Code = @Product_Code

Select Top 1 @NewSTaxCode = STaxCode From ItemsSTaxMap 
		Where Product_Code = @Product_Code and dbo.Striptimefromdate(@OPENING_DATE) 
			Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))

If @STaxCode <> IsNull(@NewSTaxCode,0)
	Update Items Set Sale_Tax = @NewSTaxCode Where Product_Code = @Product_Code	
			
Select Top 1 @NewPTaxCode = PTaxCode From ItemsPTaxMap 
		Where Product_Code = @Product_Code and dbo.Striptimefromdate(@OPENING_DATE) 
			Between dbo.Striptimefromdate(PEffectiveFrom) and dbo.Striptimefromdate(isnull(PEffectiveTo,GetDate()))

If @PTaxCode <> IsNull(@NewPTaxCode,0)
	Update Items Set TaxSuffered = @NewPTaxCode Where Product_Code = @Product_Code

End

ExitProc:   

