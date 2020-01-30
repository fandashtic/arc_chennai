
CREATE procedure sp_get_CampaignInfo
(      
 @CustomerID nVarchar(255),      
 @Default Int      
)              
As             
Create Table #TmpCampaignDrive (CampaignName nVarchar(255), ResponseType Int, CampaignID nVarchar(30))      

Insert into #TmpCampaignDrive (CampaignName, ResponseType, CampaignID)      
(Select CampaignName,ResponseType,CampaignMaster.CampaignID From  CampaignMaster,CampaignCustomers              
Where IsNull(CampaignMaster.CustomerID,0) = 1 And        
CampaignMaster.CampaignID = CampaignCustomers.CampaignID And              
CampaignCustomers.CustomerID =  @CustomerID  And           
CampaignMaster.Active = 1 And          
CampaignMaster.Todate > = getdate() And IsNull(CampaignMaster.DefaultDrive,0)=@Default
Union        
Select CampaignName,ResponseType,CampaignMaster.CampaignID From  CampaignMaster        
Where IsNull(CampaignMaster.CustomerID,0) =  0 And        
CampaignMaster.Active = 1 And          
CampaignMaster.Todate > = getdate() And IsNull(CampaignMaster.DefaultDrive,0)=@Default)      
       
Select * From #TmpCampaignDrive Order by CampaignID      
Drop Table #TmpCampaignDrive      
      
  
