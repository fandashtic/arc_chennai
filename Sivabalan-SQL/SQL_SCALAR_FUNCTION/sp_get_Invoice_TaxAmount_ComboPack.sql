Create Function [dbo].[sp_get_Invoice_TaxAmount_ComboPack]   
    (@ComboComponent_ComboId as int,  
    @Combo_Quantity as Decimal(18,6),  
    @Customer_Type as int,   
    @Locality as int,  
    @CustomerSuffersTax as int,  
    @TaxBeforeDiscount as Decimal(18,6) ,  
    @DiscountPercentage as Decimal(18,6),  
    @Price_Option as int,  
    @Function as int,
    @TaxOnEcp as Decimal(18,6) = 0)   
Returns Decimal(18,6) As  
Begin  
  Declare @TaxAmount as Decimal(18,6)  
  
  if @TaxBeforeDiscount = 1 Set @DiscountPercentage = 0  
  if @TaxOnEcp = 1 
  Begin
	--Select Only ECP Amount For Calculation
    --Discount will not be Computed For Tax on Ecp Even if it is Tax After Discount
	Set @Customer_Type = -1 
	Set @DiscountPercentage = 0
  End
  
If @Function = 0 -- Default Item Opening (i.e no Batch)   
  Select  @TaxAmount = Sum(@Combo_Quantity * Quantity *   
        (Case @Customer_Type   
        When 1 Then  
         Combo_Components.PTS  
        When 2 Then  
         Combo_Components.PTR  
        When 3 Then  
         Combo_Components.SpecialPrice  
        Else  
         Combo_Components.ECP  
        End) * (1 +    
        Case @CustomerSuffersTax When 1 Then   
         Isnull(Case @locality When 1 Then   
             A.Percentage   
            Else A.Cst_Percentage End,0) / 100   
        Else 0 End -   
        @DiscountPercentage / 100) *   
        Isnull(Case @locality When 1 Then   
             TAX.Percentage   
           Else Tax.Cst_Percentage End,0) / 100)   
  From  Combo_Components
   Inner Join Items On Items.Product_Code = Component_Item_Code 
   Left Outer Join Tax On Tax.Tax_Code = Items.Sale_Tax
   Left Outer Join Tax A On A.Tax_Code = Items.TaxSuffered     
Where  Combo_Components.ComboID = @ComboComponent_ComboId and Combo_Components.Free = 0 
   
Else  
  If @Function = 1   
  Select  @TaxAmount = Sum(@Combo_Quantity * Quantity *   
           (Case @Customer_Type   
           When 1 Then  
            Combo_Components.PTS  
           When 2 Then  
            Combo_Components.PTR  
           When 3 Then  
            Combo_Components.SpecialPrice  
           Else  
            Combo_Components.ECP  
           End) *           
           Isnull(Case @locality When 1 Then   
             A.Percentage   
           Else A.Cst_Percentage End,0) / 100 )  
           
  From  
   Combo_Components
   Inner Join Items On Items.Product_Code = Combo_Components.Component_Item_Code
   Left Outer Join Tax A  On A.Tax_Code = Items.TaxSuffered     
   Where   Combo_Components.ComboID = @ComboComponent_ComboId and Combo_Components.Free = 0
  Else   
  Begin  
   IF @Price_Option = 1   
  Select  @TaxAmount = Sum(@Combo_Quantity * Quantity *  
        (Case @Customer_Type   
        When 1 Then  
         Combo_Components.PTS  
        When 2 Then  
         Combo_Components.PTR  
        When 3 Then  
         Combo_Components.SpecialPrice  
        Else  
         Combo_Components.ECP  
        End) * (1 +    
        Case @CustomerSuffersTax When 1 Then   
          Combo_Components.TaxSuffered / 100   
        Else 0 End -   
        @DiscountPercentage / 100) *   
        Isnull(Case @locality When 1 Then   
             TAX.Percentage   
           Else Tax.Cst_Percentage End,0) / 100)   
  From  
   Combo_Components
   Inner Join  Items On Items.Product_Code = Component_Item_Code
   Left Outer Join Tax On  Tax.Tax_Code =Items.Sale_Tax
   Where  Combo_Components.ComboID = @ComboComponent_ComboId and  
 
   Combo_Components.Free = 0 
   ELSE  
  -- IF NON CSP , Then TaxSuffered and Quantity is taken from Comboid Which  
  -- is taken from Batch_Prodcucts Table and SALEPRICE is  
  -- Taken From Items Table  
  Select  @TaxAmount = Sum(@Combo_Quantity * B.Quantity *  
        (Case @Customer_Type   
        When 1 Then  
         A.PTS  
        When 2 Then  
         A.PTR  
   When 3 Then  
         A.SpecialPrice  
        Else  
         A.ECP  
        End) * (1 +    
        Case @CustomerSuffersTax When 1 Then  
         Isnull(B.TaxSuffered,0)  
        Else 0 End -   
        @DiscountPercentage / 100) *   
        Isnull(Case @locality When 1 Then   
             TAX.Percentage   
           Else Tax.Cst_Percentage End,0) / 100)   
  From  
   Combo_Components A
   Inner Join  Items I On I.ComboId = A.ComboID
   Inner Join Combo_Components B  On B.Combo_Item_Code = I.Product_Code And B.Component_Item_Code = A.Component_Item_Code And B.Free = A.Free
   Inner Join Items On B.Component_Item_Code = Items.Product_Code
   Left Outer Join Tax On Tax.Tax_Code = Items.Sale_Tax  
     Where  B.ComboID = @ComboComponent_ComboId And  B.Free = 0 
  
  END   
Return @TaxAmount  
End  


