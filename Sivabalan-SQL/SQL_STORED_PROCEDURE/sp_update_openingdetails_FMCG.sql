CREATE PROCEDURE sp_update_openingdetails_FMCG(@OPENING_DATE datetime)  
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

--To Update Van Stock into Batch_Products
Update Batch_Products_Copy Set Quantity = Batch_Products_Copy.Quantity + IsNull(VanStatementDetail_Copy.Pending,0) 
From Batch_Products_Copy, VanStatementAbstract_Copy, VanStatementDetail_Copy 
WHERE VanStatementDetail_Copy.Batch_Code=Batch_Products_Copy.Batch_Code AND 
VanStatementAbstract_Copy.DocSerial = VanStatementDetail_Copy.DocSerial AND 
(VanStatementAbstract_Copy.Status & 128) = 0 

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
		WHERE (Isnull(a.Status, 0) & 128) = 0 and (Isnull(JobcardAbstract.Status, 0) & 128) = 0
	end

DECLARE GetOpeningDetails CURSOR STATIC FOR  
SELECT BPC.Product_Code, SUM(BPC.Quantity), SUM(ISNULL(BPC.Quantity, 0) * ISNULL(BPC.PurchasePrice, 0)),  
(Sum(Case IsNull(BPC.ApplicableOn,0) 
When 1 then (IsNull(BPC.PurchasePrice,0) * IsNull(BPC.Quantity,0) * (((IsNull(BPC.TaxSuffered,0) * IsNull(BPC.PartOfPercentage,0)) / 100) / 100))      
When 6 then (IsNull(Items.MRP,0) * IsNull(BPC.Quantity,0) * (((IsNull(BPC.TaxSuffered,0) * IsNull(BPC.PartOfPercentage,0)) / 100) / 100))
Else 0
End)/
Case When Sum(IsNull(BPC.Quantity, 0) *  IsNull(BPC.PurchasePrice, 0)) = 0 Then 1   
Else Sum(IsNull(BPC.Quantity, 0) *  IsNull(BPC.PurchasePrice, 0)) End)*100,
--Calculation for CST TaxSuffered Percentage
Case When (Select IsNull(Vat,0) from Items Where Items.Product_Code=BPC.Product_Code) = 1
  	  Then (Sum(Case IsNull(BPC.Vat_Locality,0) When 2 Then DBO.FN_GetTaxSufferedAmt_FMCG(IsNull(BPC.PurchasePrice,0), IsNull(Items.MRP,0), IsNull(BPC.Quantity, 0), IsNull(BPC.TaxSuffered,0), IsNull(BPC.ApplicableOn, 0), IsNull(BPC.PartOfPercentage, 0), BPC.Batch_Code) Else 0 End) /  
		  	  Case When Sum(IsNull(BPC.Quantity, 0) *  IsNull(BPC.PurchasePrice, 0)) = 0 Then 1     
		     Else Sum(IsNull(BPC.Quantity, 0) *  IsNull(BPC.PurchasePrice, 0)) End)*100 
	  Else 0 End 
FROM Batch_Products_Copy BPC, Items
Where Items.Product_Code = BPC.Product_Code
GROUP BY BPC.Product_Code  
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

 SELECT  @FreeQty = ISNULL(SUM(Quantity), 0) FROM Batch_Products_Copy  
 WHERE  Product_Code = @Product_Code AND ISNULL(PurchasePrice, 0) = 0  

 UPDATE OpeningDetails SET 
 Free_Opening_Quantity = @FreeQty, Free_Saleable_Quantity = @FreeSaleable, 
 Damage_Opening_Quantity = @DamageQty, Damage_Opening_Value = @DamageValue
 WHERE Product_Code = @Product_Code and Opening_Date = @OPENING_DATE  
 FETCH NEXT FROM GetOpeningDetails INTO @Product_Code, @OpeningQty, @OpeningValue, @TaxSuffered, @CSTTaxSuffered     
  
END  
CLOSE GetOpeningDetails  
DEALLOCATE GetOpeningDetails  



