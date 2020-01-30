CREATE Procedure sp_acc_computestockbalance(@AccountID int)  
As  
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
  
Select @OpeningDate = dbo.stripdatefromtime(OpeningDate) from Setup  
  
If @AccountID = @OPENING_STOCK  
Begin  
 Select @AccountBalance = Sum(opening_Value)from OpeningDetails, Items  
 where Opening_Date = @OpeningDate And OpeningDetails.Product_Code = Items.Product_Code  
 Set @AccountBalance =IsNULL(@AccountBalance,0)  
End  
If @AccountID = @CLOSING_STOCK  
Begin  
 Select @AccountBalance = IsNULL(dbo.sp_acc_getClosingStock(),0)  
 Set @AccountBalance = IsNULL(@AccountBalance,0)  
End  
If @AccountID = @TAXON_OPENING_STOCK  
Begin  
 Select @AccountBalance = Sum(Case When IsNULL(Items.VAT,0) = 1 Then     
 (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then    
 (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else    
 (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then    
 (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)    
 from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code    
 And Opening_Date = @OpeningDate    
 Set @AccountBalance = IsNULL(@AccountBalance,0)  
End  
If @AccountID = @TAXON_CLOSING_STOCK  
Begin  
 Select @AccountBalance = IsNULL(dbo.sp_acc_getTaxonClosingStock(),0)   
End  
Select 'Balance' = @AccountBalance 
