CREATE Procedure sp_get_LastCollectionID     
As    
-- If @Retail=1    
--  Select Top 1 DocumentID From Collections  Where IsNull(Status, 0) & 32 = 32 Order By DocumentID Desc    
-- Else    
--  Select Top 1 DocumentID From Collections Where ISNULL(Status,0) & 32 = 0  Order By DocumentID Desc    
Select Top 1 DocumentID From Collections   
Where CustomerId <> 'GIFT VOUCHER'  
Order By DocumentID Desc    



