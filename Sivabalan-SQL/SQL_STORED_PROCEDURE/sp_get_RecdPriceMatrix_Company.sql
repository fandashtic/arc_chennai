
CREATE Procedure sp_get_RecdPriceMatrix_Company  
As  
Select "Party Code" = IsNull(PartyCode, N''),  
 "Count Of Items" = Count(Distinct ItemCode),
 "Serial" = Serial  
From PricingAbstractReceived     
Where IsNull(Flag, 0) & 32 = 0
Group By Serial, PartyCode  
Order By Serial

