
CREATE Procedure FSU_Sp_getBuildVersion
as  
	select Top 1 Version from setup
