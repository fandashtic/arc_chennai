CREATE procedure Sp_Load_CampaignCustomers_Chevron(@Campaignid nvarchar(15)) 
As  

Select 
	CustomerId,CustomerObjective
From 
	CampaignCustomers 
Where 
	CampaignID=@Campaignid 
Order by 
	Serial 

SET QUOTED_IDENTIFIER OFF 
