CREATE procedure Sp_Delete_CampaignCustomers (@Code nvarchar(15)) as  
delete from CampaignCustomers where CampaignID=@code  


