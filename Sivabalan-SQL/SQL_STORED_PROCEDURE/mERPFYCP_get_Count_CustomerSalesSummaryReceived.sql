CREATE Procedure mERPFYCP_get_Count_CustomerSalesSummaryReceived   ( @yearenddate datetime )
as  
--Lists all the Unprocessed CustomerPoints  
Select Count(*) from CustomerSalesSummaryAbstract Where isnull(Status,0)=0 and DocumentDate <= @yearenddate  
