CREATE Procedure sp_Save_Invoice_ComboComponents(@INVOICE_ID int,    
  @Invoice_ComboID int,    
  @Combo_Components_ComboID int,    
  @CustomerSuffers int,    
  @TaxBeforeDiscount Decimal(18,6),    
  @CUSTOMER_TYPE int,    
  @Price_Option int,    
  @FREE_ROW Decimal(18,6),    
  @TradeDiscount Decimal(18,6),    
  @AdditionalDiscount Decimal(18,6),  
  @TaxOnECP int = 0)    
As    
    
DECLARE @LOCALITY int, @Combo_Quantity Decimal(18,6), @SALEID Int, @Free Decimal(18,6)    
DECLARE @Combo_Item_Code nvarchar(30), @Component_Item_Code nvarchar(20) , @Quantity Decimal(18,6)    
DECLARE @PTS Decimal(18,6) , @PTR Decimal(18,6), @ECP Decimal(18,6), @SpecialPrice Decimal(18,6), @TaxSuffered Decimal(18,6)    
DECLARE @SalePrice Decimal(18,6), @PurchasePrice Decimal(18,6), @TaxSufferedValue Decimal(18,6)    
DECLARE @TaxCode Decimal(18,6), @TaxCode2 Decimal(18,6), @STPayable Decimal(18,6), @CSTPayable Decimal(18,6)    
DECLARE @TotalAmount Decimal(18,6), @DiscountPercentage Decimal(18,6), @DiscountValue Decimal(18,6), @TaxID int    
DECLARE @StCreditValue Decimal(18,6), @StCreditValue2 Decimal(18,6), @TotalQuantity Decimal(18,6)    
DECLARE @GrossAmount Decimal(18,6), @NetAmount Decimal(18,6), @AddDiscountValue Decimal(18,6)    
    
Select @LOCALITY = IsNull(Locality, 0) From InvoiceAbstract, Customer     
Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @INVOICE_ID      
    
IF @LOCALITY = 0 SET @LOCALITY = 1      
    
Select  @COMBO_QUANTITY = Sum(Quantity),    
  @TAXSUFFERED = Max(TaxSuffered),    
  @DISCOUNTPERCENTAGE = Max(DiscountPercentage)     
From    
 InvoiceDetail    
Where    
 InvoiceID = @Invoice_ID and    
 ComboId = @Invoice_ComboID    
Group by InvoiceID, ComboID    
    
IF @CUSTOMERSUFFERS = 0 SET @TaxSuffered = 0    
    
IF @Price_Option = 1     
 DECLARE ComboCursor CURSOR KEYSET FOR     
  SELECT  Combo_Item_Code, Component_Item_Code, Quantity, Free, PTS, PTR, ECP,     
    SpecialPrice, TaxSuffered     
  FROM Combo_Components Where ComboID = @Combo_Components_ComboID    
Else    
 -- if CSP is not Set Then TAXSUFFERED AND QTY is taken from Batch_Products COMBOID and    
 -- PTS, PTR ... Prices are Taken From ITEMS Table COMBOID     
 DECLARE ComboCursor CURSOR KEYSET FOR     
  SELECT  B.Combo_Item_Code, B.Component_Item_Code, A.Quantity, A.Free, B.PTS, B.PTR, B.ECP,     
    B.SpecialPrice, A.TaxSuffered     
  FROM Combo_Components A, Items, Combo_Components B    
  Where  A.ComboID = @Combo_Components_ComboID And     
    Items.Product_Code = A.Combo_Item_Code And    
    Items.ComboID = B.ComboID And    
    A.Component_Item_Code = B.Component_Item_Code And    
    A.Free = B.Free    
    
OPEN ComboCursor    
    
FETCH FROM ComboCursor INTO @Combo_Item_code,    
 @Component_Item_Code, @Quantity, @Free, @PTS, @PTR, @ECP, @SpecialPrice, @TaxSuffered    
    
WHILE @@FETCH_STATUS = 0    
Begin    
 Set @TaxCode2 = 0    
 Set @CSTPayable = 0    
 Set @StCreditValue2 = 0    
    
 SET @TotalQuantity = @Quantity * @Combo_Quantity    
    
 Select @PurchasePrice = (CASE Purchased_At When 1 Then PTS When 2 Then PTR ELSE 0 END),    
     @TaxID = Sale_Tax,     
     @TaxCode = (CASE @LOCALITY When 1 Then Percentage Else CST_Percentage END),    
     @SaleId = SaleID    
 From Items, Tax Where Sale_Tax = Tax_Code and Product_Code = @Component_Item_Code     
    
 IF @Free = 0 And @FREE_ROW = 0    
 Begin    
  IF @Customer_Type = 1     
   SET @SALEPRICE = @PTS    
  ELSE IF @Customer_Type = 2    
   SET @SALEPRICE = @PTR    
  ELSE IF @Customer_Type = 3    
   SET @SALEPRICE = @SpecialPRice    
  ELSE
   SET @SALEPRICE = @ECP     

  SET @GrossAmount = @TotalQuantity * @SalePrice    
  If @TaxOnEcp = 1  
 SET @TaxSufferedValue = @TotalQuantity * @ECP * ((@TaxSuffered/(100-@TaxSuffered))*100) / 100.0     
  Else  
   SET @TaxSufferedValue = @GrossAmount * @TaxSuffered / 100.0     
  SET @DiscountValue = @GrossAmount * @DiscountPercentage / 100.0    
  SET @NETamount = @GrossAmount - @DiscountValue    
  SET @AddDiscountValue = @NetAmount * (@AdditionalDiscount + @TradeDiscount) / 100    
  SET @StCreditValue = 0    
If @TaxOnEcp = 0  
  Begin  
 If @TaxBeforeDiscount = 1    
   SET @STPayable = (@GrossAmount + @TaxSufferedValue) * @TaxCode / 100.0    
 Else    
 Begin    
   SET @STPayable = (@GrossAmount + @TaxSufferedValue - @DiscountValue) * @TaxCode / 100.0    
--   Set @StCreditValue = @STPayable * (@AdditionalDiscount + @TradeDiscount) / 100    
	Set @StCreditValue = @AddDiscountValue * @TaxCode / 100    
 End    
 Set @TotalAmount =  @GrossAmount + @TaxSufferedValue - @DiscountValue +     
     @STPayable - @AddDiscountValue - @StCreditValue    
  End  
  Else  
 SET @STPayable = (@TotalQuantity * @ECP + @TaxSufferedValue) * ((@TaxCode/(100-@TaxCode))*100) / 100.0    
     
  If @Locality = 2    
  Begin    
   Set @TaxCode2 = @TaxCode    
   Set @CSTPayable = @StPayable    
   Set @StCreditValue2 = @StCreditValue    
   Set @TaxCode = 0    
   Set @StPayable = 0    
   Set @StCreditValue = 0    
  End    
  --, StCreditValue, StCreditValue2    
  --, @StCreditValue, @StCreditValue2    
  Insert Into Invoice_Combo_Components     
   (InvoiceID, Combo_Item_Code, Component_Item_Code, Quantity, SalePrice, PurchasePrice,    
   PTS, PTR, ECP, SpecialPrice, TaxSuffered, TaxSufferedValue, TaxCode, TaxCode2,    
   STPayable, CSTPayable, Amount, SaleID, DiscountPercentage, DiscountValue, ComboID,    
   TAXID, TradeDiscount, AdditionalDiscount)    
   Values    
   (@Invoice_ID, @Combo_Item_Code, @Component_Item_Code, @TotalQuantity, @SalePrice, @PurchasePrice,    
   @PTS, @PTR, @ECP, @SpecialPrice, @TaxSuffered, @TaxSufferedValue, @TaxCode, @TaxCode2,    
   @STPayable - @StCreditValue, @CSTPayable - @StCreditValue2, @TotalAmount, @SaleID, @DiscountPercentage, @DiscountValue,     
   @Invoice_ComboID, @TAXID, @TradeDiscount, @AdditionalDiscount)    
    
 End    
 ELse    
  Insert Into Invoice_Combo_Components     
   (InvoiceID, Combo_Item_Code, Component_Item_Code, Quantity,    
   SaleID, ComboID)    
  Values    
   (@Invoice_ID, @Combo_Item_Code, @Component_Item_Code, @TotalQuantity,    
   @SaleID, @Invoice_ComboID)    
     
 FETCH FROM ComboCursor INTO @Combo_Item_code,    
 @Component_Item_Code, @Quantity, @Free, @PTS, @PTR, @ECP, @SpecialPrice, @TaxSuffered    
    
End    
Close ComboCursor    
DeAllocate ComboCursor    

