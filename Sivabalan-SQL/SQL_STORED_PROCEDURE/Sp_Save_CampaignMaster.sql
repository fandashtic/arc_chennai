CREATE procedure Sp_Save_CampaignMaster(@CampaignId nvarchar(15),@CampaignName nvarchar(510), @Desccription nvarchar(510),@fromdate datetime,        
@ToDate Datetime,@Memo1 nvarchar(510), @Memo2 nvarchar(510),@Memo3 nvarchar(510),@Response int,@Objective Decimal(18,6), @CreateDate datetime, @CustAll int)as        
        
insert into CampaignMaster(     
CampaignID,       
CampaignName,        
Description,        
FromDate,        
ToDate,        
Memo1,        
Memo2,        
Memo3,        
ResponseType,        
Objective,        
Active,        
CreationDate,  
CustomerID)        
Values(    
@CampaignId,    
@CampaignName,         
@Desccription,        
@fromdate,        
@ToDate,        
@Memo1,        
@Memo2,        
@Memo3,        
@Response,        
@Objective,        
1,        
@CreateDate,  
@CustAll )        
      
    
    
    
    
  


