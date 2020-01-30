CREATE VIEW [dbo].[V_Asset_Outlet]  
AS  
	Select Distinct CustomerID,DSID,AssetNumber,AssetTypeID,AssetType,AssetStatus from dbo.fn_V_Asset_Outlet()
