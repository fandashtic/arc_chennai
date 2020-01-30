CREATE Procedure sp_acc_totalbalances      
as    
Declare @Debit Decimal(18,6)    
Declare @Credit Decimal(18,6)    
Declare @OpeningBalance Decimal(18,6)    
Declare @OpeningDate DateTime    
Declare @OpeningTaxBalance Decimal(18,6)    
    
Select @OpeningDate = OpeningDate from Setup    
    
Select @OpeningBalance = Sum(IsNULL(Opening_Value,0)),    
@OpeningTaxBalance = Sum(Case When IsNull(Items.VAT,0) = 1 Then       
(Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then      
(IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else      
(Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then      
(IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)      
from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code      
And Opening_Date = @OpeningDate    
    
Set @OpeningBalance = IsNULL(@OpeningBalance,0) + IsNULL(@OpeningTaxBalance,0)    
    
-- 22 = OPENING_STOCK    
-- 89 = TAXON_OPENING_STOCK     
-- 23 = CLOSING_STOCK     
-- 88 = TAXON_CLOSING_STOCK    
    
Select @Debit = sum(IsNULL(OpeningBalance,0))    
from AccountsMaster where IsNULL(OpeningBalance,0)> 0    
and AccountID not in (22,23,88,89)    
    
Select @Credit = abs(sum(IsNULL(OpeningBalance,0)))    
from AccountsMaster where IsNULL(OpeningBalance,0)< 0    
and AccountID not in (22,23,88,89)    
    
Set @Debit = IsNULL(@Debit,0) + @OpeningBalance    
    
Select IsNULL(@Debit,0),IsNULL(@Credit,0) 
