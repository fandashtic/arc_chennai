CREATE procedure Sp_Load_CampaignCustomers(@Campaignid nvarchar(15)) as  
select customerid from CampaignCustomers where CampaignID=@Campaignid order by serial 


