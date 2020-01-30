CREATE procedure Sp_Load_CampaignMaster(@Campaignid nvarchar(15)) as  
select CampaignID,CampaignName,Description,FromDate,  
 ToDate,Memo1,Memo2,Memo3,  
 ResponseType,Objective,Active,CustomerID from CampaignMaster where campaignid=@Campaignid  
  


