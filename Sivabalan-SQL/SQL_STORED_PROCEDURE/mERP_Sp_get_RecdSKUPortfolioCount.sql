Create Procedure mERP_Sp_get_RecdSKUPortfolioCount  
As  
Begin  
 Select Count(distinct DocumentID) From Recd_SKUPortfolio Where isnull(Status,0) = 0  
End  
