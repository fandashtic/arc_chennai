CREATE Procedure spr_Asset_Tracking_Detail_ITC ( @AssetID int,     
@FromDate datetime,         
@ToDate datetime,
@CustomerID Varchar(10) = '',
@CustomerName Varchar(20) = '',
@Status Varchar(10) = '')        
AS        
Begin  
	
	Create Table #tempAssetDetail(SalesManid int,Salesman_Name nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
						 Status nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS, 
						 Statusid int,						 
			 			 AssetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
						 Source nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,	
						 Reason nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,					
						 CreationDate DateTime,
						 DownloadedDate DateTime)

    insert into #tempAssetDetail(SalesManid,Status,Statusid,AssetType,Source,Reason,CreationDate,DownloadedDate)
	select DSID,
		   AssetStatus,
		   (Case AssetStatus When 'New' Then 1 Else 
			Case AssetStatus When 'Verified' Then 2 Else 
		    Case AssetStatus When 'Rejected' Then 3 Else
			0 End End End ) as "Statusid",		  
		   AssetType,					   
		   Source,           
		   (Case isnull(Reason,'') When '' Then 'N/A' Else 
			isnull(Reason,'') End) as "Reason",
		   CreationDate,
		   DownloadedDate		   
	From   AssetDetail
	Where  AssetID in ( @AssetID ) And 
		   DownloadedDate Between @FromDate and @ToDate 

    Update t set t.Salesman_Name = s.Salesman_Name From #tempAssetDetail t,SalesMan s Where t.SalesManid = s.SalesmanID
	
	
		   select ''			     As  "Assetid",
		   isnull(Salesman_Name,'')	 As  "Salesman Name",
		   Status               	 As  "Status",
		   AssetType                 As  "Asset Type",
		   Source                    As  "Source",
		   Reason                    As  "Reason",
		   (Convert(varchar(10), CreationDate, 103)+ ' ' + Convert(varchar(10), CreationDate, 108))
					                 As  "Creation Time",	
		   (Convert(varchar(10), DownloadedDate, 103)+ ' ' + Convert(varchar(10), DownloadedDate, 108))
									 As  "Download Time"
    From   #tempAssetDetail
	Order by DownloadedDate,Salesman_Name desc,Statusid

	Drop Table #tempAssetDetail
End 		   		 	
