CREATE PROCEDURE sp_update_openingdetails(@OPENING_DATE datetime)  
AS  
DECLARE @Product_Code nvarchar(15)   
DECLARE @OpeningQty Decimal(18,6)   
DECLARE @OpeningValue Decimal(18,6)   
DECLARE @DamageQty Decimal(18,6)   
DECLARE @DamageValue Decimal(18,6)   
DECLARE @FreeSaleable Decimal(18,6)   
DECLARE @FreeQty Decimal(18,6)   
DECLARE @TaxSuffered Decimal(18,6)   
DECLARE @CSTTaxSuffered Decimal(18,6)   
  
if Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')  
 Drop Table VanPending  
  
Select "Batch_Code" = VanStatementDetail_Copy.Batch_Code, "VanQty" = Sum(IsNull(VanStatementDetail_Copy.Pending, 0))  
Into VanPending From VanStatementDetail_Copy, VanStatementAbstract_Copy Where   
VanStatementAbstract_Copy.DocSerial = VanStatementDetail_Copy.DocSerial AND   
(VanStatementAbstract_Copy.Status & 128) = 0   
group by VanStatementDetail_Copy.Batch_Code  
  
--To Update Van Stock into Batch_Products  
Update Batch_Products_Copy Set Quantity = Batch_Products_Copy.Quantity + VanPending.VanQty  
From Batch_Products_Copy, VanPending   
Where Batch_Products_Copy.Batch_code = VanPending.Batch_Code  

if Exists(Select * from SysObjects Where Name like 'VanPending' And xtype = 'U')  
 Drop Table VanPending  
  
--**************************************************************************************************************************  
--This SQL is commented as it does not add up stocks from same batch  
--**************************************************************************************************************************  
-- Update Batch_Products_Copy Set Quantity = Batch_Products_Copy.Quantity + (IsNull(VanStatementDetail_Copy.Pending,0))  
-- From Batch_Products_Copy, VanStatementAbstract_Copy, VanStatementDetail_Copy   
-- WHERE VanStatementDetail_Copy.Batch_Code=Batch_Products_Copy.Batch_Code and   
-- VanStatementAbstract_Copy.DocSerial = VanStatementDetail_Copy.DocSerial AND   
-- (VanStatementAbstract_Copy.Status & 128) = 0   
--**************************************************************************************************************************  


/* Service module Issue opening detail*/
	If exists(Select * From SysObjects Where xtype = 'U' And Name = 'IssueAbstract') 
	and exists(Select * From SysObjects Where xtype = 'U' And Name = 'IssueDetail')
	begin 
		Update b Set Quantity = b.Quantity 
		+ IsNull(d.IssuedQty, 0) - Isnull(d.ReturnedQty,0) 
		From Batch_Products_Copy b
		Inner Join IssueDetail_Copy d On d.Batch_Code = b.Batch_Code 
		Inner Join IssueAbstract_Copy a On a.IssueID = d.IssueID 
		Inner Join JobcardAbstract On JobcardAbstract.JobCardID = a.JobCardID
		WHERE (Isnull(a.Status, 0) & 128) = 0 and (Isnull(JobcardAbstract.Status, 0) & (128 | 32) ) = 0
	end  
  
DECLARE GetOpeningDetails CURSOR STATIC FOR      
SELECT Product_Code, SUM(Quantity), SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)),      
--Calculation : (Sum(TaxSufferedAmt)/Sum(Amt)) * 100    
(Sum(DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code)) /    
Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1       
Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100,  
--Calculation for CST TaxSuffered Percentage  
Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=Batch_Products_Copy.Product_Code) = 1  
     Then (Sum(Case IsNull(Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt(Product_Code, IsNull(PurchasePrice,0), IsNull(Quantity, 0), IsNull(TaxSuffered,0), IsNull(ApplicableOn, 0), IsNull(PartOfPercentage, 0), Batch_Code) Else 0 End) /    
       Case When Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) = 0 Then 1       
       Else Sum(IsNull(Quantity, 0) *  IsNull(PurchasePrice, 0)) End)*100   
   Else 0 End   
FROM Batch_Products_Copy   
GROUP BY Product_Code      
OPEN GetOpeningDetails      
      
FETCH FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered      
WHILE @@FETCH_STATUS = 0      
BEGIN      
 INSERT INTO OpeningDetails(Product_Code, Opening_Date, Opening_Quantity,       
 Opening_Value, TaxSuffered_Value, CST_TaxSuffered)      
 VALUES (@Product_Code, @OPENING_DATE, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered)      
  
 SELECT  @DamageQty = ISNULL(SUM(Quantity), 0), @DamageValue = SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) FROM Batch_Products_Copy      
 WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) <> 0      
  
 SELECT  @FreeSaleable = ISNULL(SUM(Quantity), 0) FROM Batch_Products_Copy   
 WHERE  Product_Code = @Product_Code And ISNULL(Damage,0) = 0 And ISNULL(PurchasePrice, 0) = 0      
  
 SELECT  @FreeQty = SUM(Quantity) FROM Batch_Products_Copy      
 WHERE  Product_Code = @Product_Code And PurchasePrice = 0      
   
 UPDATE OpeningDetails SET   
 Free_Opening_Quantity = @FreeQty, Free_Saleable_Quantity = @FreeSaleable, --+ @VanFreeQty      
 Damage_Opening_Quantity = @DamageQty, Damage_Opening_Value = @DamageValue   
 WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE      
 FETCH NEXT FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered      
END      
CLOSE GetOpeningDetails      
DEALLOCATE GetOpeningDetails  

