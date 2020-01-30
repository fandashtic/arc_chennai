CREATE Procedure sp_Get_Count_CustomerSalesSummaryReceived  
as  
--Lists all the Unprocessed CustomerPoints  
Select Count(*) from CustomerSalesSummaryAbstract Where isnull(Status,0)=0  


