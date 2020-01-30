CREATE function sp_acc_computestockbalancefn(@AccountID int)    
returns Decimal(18,6)    
Begin    
Declare @AccountBalance Decimal(18,6)    
Declare @OpeningDate Datetime    
    
Declare @OPENING_STOCK Int    
Declare @CLOSING_STOCK Int     
Declare @TAXON_OPENING_STOCK Int    
Declare @TAXON_CLOSING_STOCK Int     
    
Set @OPENING_STOCK = 22    
Set @CLOSING_STOCK = 23    
Set @TAXON_OPENING_STOCK = 89    
Set @TAXON_CLOSING_STOCK = 88    
    
Select @OpeningDate = OpeningDate from Setup    
Set @OpeningDate = dbo.stripdatefromtime(@OpeningDate)  
  
If @AccountID = @OPENING_STOCK    
Begin    
 Select @AccountBalance = sum(opening_Value)from OpeningDetails    
 where Opening_Date = @OpeningDate    
 Set @AccountBalance =isnull(@AccountBalance,0)    
End    
If @AccountID = @CLOSING_STOCK    
Begin    
 Select @AccountBalance= isnull(dbo.sp_acc_getClosingStock(),0)    
 Set @AccountBalance =isnull(@AccountBalance,0)    
End    
If @AccountID = @TAXON_OPENING_STOCK    
Begin    
 Select @AccountBalance =Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then     
 (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails     
 where Opening_Date = @OpeningDate    
 Set @AccountBalance =isnull(@AccountBalance,0)    
End    
If @AccountID = @TAXON_CLOSING_STOCK    
Begin    
 Select @AccountBalance= isnull(dbo.sp_acc_getTaxonClosingStock(),0)     
End    
return @AccountBalance    
End 
