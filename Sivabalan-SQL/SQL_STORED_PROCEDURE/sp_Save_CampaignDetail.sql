CREATE Procedure sp_Save_CampaignDetail(@SVNumber Int,@CampaignId nVarchar(15),@Response Decimal(18,6), @ResponseType Int)      
As      
Insert Into CampaignDrives (SVNumber,CampaignID,Response,ResponseType) Values (@SVNumber,@CampaignId,@Response,@ResponseType)      
    
    
  


