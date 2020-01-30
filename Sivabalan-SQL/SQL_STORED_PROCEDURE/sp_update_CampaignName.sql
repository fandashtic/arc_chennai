create Procedure sp_update_CampaignName (@Campaignid Varchar(30),        
         @NewName Varchar(510))        
As        
Update campaignmaster  Set CampaignName  = @NewName      
Where CampaignID = @Campaignid  


