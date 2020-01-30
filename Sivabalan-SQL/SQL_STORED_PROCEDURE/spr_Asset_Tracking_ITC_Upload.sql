CREATE Procedure spr_Asset_Tracking_ITC_Upload (    
@AssetType Nvarchar(4000),
@AssetNo  Nvarchar(4000),
@FromDate datetime,         
@ToDate datetime,
@CustomerID Nvarchar(4000),
@Status Nvarchar(100))        
AS        
Begin  
Declare @WDCode nVarchar(255)  
Declare @WDDest nVarchar(255)  
Declare @CompaniesToUploadCode nVarchar(255) 
Declare @Delimeter  Char(1), @IPrefix as nVarchar(255) ,@IAPrefix as nVarchar(255) 
Declare @CustomerName Nvarchar(4000) 

Set @Delimeter = Char(15)
Set @CustomerName  = 'A'
Create table #tmpAssetID(AssetID int)  

Create table #tempAssetType (AssetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, AssetTypeID int)

Create table #tempAssetNo   (AssetNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempCustomerid (CustomerID nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempCustomerName (CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempStatus (Status  nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS )

Create table #tempAssetDetail (AssetID int,DSID int,Source  nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,CreationDate Datetime,DownloadedDate Datetime)

Create table #tempAssetUpload (WDCode nVarchar(255),WDDest nVarchar(255),FromDate datetime,ToDate datetime, AssetNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,   
								AssetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerID nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
								CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesmanID int,Status nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
								CreationTime varchar(50),DownloadTime varchar(50))

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup         

	If @CompaniesToUploadCode='ITC001'    
	   Set @WDDest= @WDCode    
	Else    
	Begin    
		 Set @WDDest= @WDCode    
		 Set @WDCode= @CompaniesToUploadCode    
	End    
   
    if @AssetType = '%' 
	Begin
		Insert into #tempAssetType (AssetTypeID) Select NULL	
		--insert into #tempAssetType select distinct Assettype  from AssetMaster
		insert into #tempAssetType (AssetTypeID) select distinct AssetTypeID  from AssetMaster
	End
	else
		insert into #tempAssetType (AssetTypeID) select distinct AssetTypeID  from AssetMaster Where Assettype in (Select * From Dbo.sp_SplitIn2Rows(@AssetType,@Delimeter))

--	Update T Set T.AssetTypeID = A.AssetTypeID From #tempAssetType T, AssetMaster A
--	Where T.AssetType = A.AssetType

	if @AssetNo = '%' 
		insert into #tempAssetNo   select distinct AssetNumber  from AssetAbstract
	else
		insert into #tempAssetNo   select distinct AssetNumber  from AssetAbstract Where AssetNumber in (Select * From Dbo.sp_SplitIn2Rows(@AssetNo,@Delimeter))
	
	if @CustomerID = '%'
		insert into #tempCustomerid select distinct CustomerID  from AssetAbstract	
	else
		insert into #tempCustomerid select distinct CustomerID  from AssetAbstract	Where CustomerID in (Select * From Dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)) 
	
    if @CustomerName = '%'
		insert into #tempCustomerName select distinct Company_Name  from Customer Where CustomerID in (select distinct CustomerID  from AssetAbstract)
	else
	    insert into #tempCustomerName select distinct Company_Name  from Customer Where Company_Name in (Select * From Dbo.sp_SplitIn2Rows(@CustomerName,@Delimeter)) 
	if @Status ='%'
		Begin
		Insert into #tempStatus select 'New'
		Insert into #tempStatus select 'Verified'
		Insert into #tempStatus select 'Rejected'
		End
	else
		Insert into #tempStatus Select * From Dbo.sp_SplitIn2Rows(@Status,@Delimeter)


	--insert into #tmpAssetID
	--select distinct AssetID From AssetDetail Where DownloadedDate between @FromDate and @ToDate  

	insert into #tempAssetDetail
	select Assetid, dsid,Source ,Max(CreationDate),max(DownloadedDate) from assetdetail Where AssetID in
   (select distinct AssetID From AssetDetail Where DownloadedDate between @FromDate and @ToDate And Source='HH') 
--	Group by Assetid,dsid,Source,CreationDate
	Group by Assetid,dsid,Source

	
	
	insert into #tempAssetUpload
	select	   
		   @WDCode					  as "WDCode",
		   @WDDest					  as "WD Dest",
           @FromDate				  as "From Date",
		   @ToDate					  as "To Date",
		   AssetNumber				  as "Asset No",
		   AssetAbstract.AssetType	  as "Asset Type",
		   AssetAbstract.CustomerID   as "Customer ID",	
		   Company_Name				  as "Customer Name",
		   AssetDetail.DSID			  as "SalesmanID",
		   AssetAbstract.AssetStatus  as "Status",		   
		   (Convert(varchar(10), AssetDetail.CreationDate, 103)+ ' ' + Convert(varchar(10), AssetDetail.CreationDate, 108))
									  as "Creation Time",
		   (Convert(varchar(10), AssetDetail.DownloadedDate, 103)+ ' ' + Convert(varchar(10), AssetDetail.DownloadedDate, 108))
									  as "Download Time"			
	From   AssetAbstract,#tempAssetDetail as AssetDetail,Customer
	--Where  AssetAbstract.AssetID in (Select AssetID From #tmpAssetID) And 
    Where  AssetAbstract.AssetID = AssetDetail.AssetID And 
		   IsNull(AssetAbstract.AssetTypeID, 0) in (Select IsNull(AssetTypeID, 0)  From #tempAssetType) And
		   AssetAbstract.AssetNumber in (Select  AssetNumber From #tempAssetNo) And
		   AssetAbstract.CustomerID in (Select  CustomerID From #tempCustomerid) And	
		   AssetAbstract.AssetStatus in (Select Status  From #tempStatus) And		    			
		   AssetDetail.Source='HH' And AssetAbstract.CustomerId = Customer.Customerid		   	
    Order By AssetDetail.DownloadedDate,AssetAbstract.CustomerId,AssetDetail.DSID	

	

    
	Select "_1" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDCode, '')),  
		   "_2" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(WDDest, '')),  
           "_3" = Convert(nVarchar(10),FromDate,103),  
           "_4" = Convert(nVarchar(10),ToDate,103),  
		   "_5" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(AssetNumber, '')),	
		   "_6" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(AssetType, '')),
           "_7" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerID, '')),  
           "_8" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CustomerName, '')),
		   "_9" = isnull(SalesmanID,0), 
		   "_10" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(Status, '')),
           "_11" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(CreationTime, '')),  
           "_12" = dbo.mERP_fn_FilterSplChar_ITC(IsNull(DownloadTime, ''))  
 	From  #tempAssetUpload As Abstract For XML Auto, ROOT ('Root')    

	

	

    Drop table #tempAssetUpload
	Drop table #tmpAssetID
	Drop table #tempAssetType
	Drop table #tempAssetNo
	Drop table #tempCustomerid
	Drop table #tempCustomerName
	Drop table #tempStatus
	Drop table #tempAssetDetail
End 		   		 	
