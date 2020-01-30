CREATE procedure FSU_sp_getMaxFSUID  
(@ClientID int)
as  
Select isnull(max(FSUID),0) as "FSUID" from tblInstallationDetail 
where 
ClientID = @ClientID 
and Status&4 = 4
