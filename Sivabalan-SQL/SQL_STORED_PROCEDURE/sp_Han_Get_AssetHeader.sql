CREATE Procedure sp_Han_Get_AssetHeader
As  

Select AssetHeaderID, "CustomerID" = IsNull(CustomerID, ''), "DSID" = IsNull(DSID, 0), "AssetNumber" = IsNull(AssetNumber, ''), 
		"AssetType" = IsNull(AssetType, ''), "AssetStatus" = IsNull(AssetStatus, ''), "Source" = IsNull(Source, ''), 
		"Reason" = IsNull(Reason, ''), DownloadedDate
From AssetInfoTracking_HH
Where IsNull(Status, 0) = 0 

