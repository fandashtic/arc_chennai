
CREATE procedure sp_Load_CampaignDrives
(
	@SVNumber Int,
 @DefaultDrives Int
)
As

Select 
	CM.CampaignName,CD.Response,CD.CampaignID,CM.ResponseType
From 
	CampaignDrives CD, CampaignMaster CM
Where 
	CD.CampaignID = CM.CampaignID
	And CD.SvNumber = @SVNumber
	And IsNull(CM.DefaultDrive,0)=@DefaultDrives

