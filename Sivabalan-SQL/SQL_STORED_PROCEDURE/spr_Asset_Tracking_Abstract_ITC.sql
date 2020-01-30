CREATE Procedure spr_Asset_Tracking_Abstract_ITC (    
@AssetType Nvarchar(4000),
@AssetNo  Nvarchar(4000),
@FromDate datetime,         
@ToDate datetime,
@CustomerID Nvarchar(4000),
@Status Nvarchar(100),
@CustomerName Nvarchar(4000) = 'A')        
AS        
Begin  
Declare @WDCode nVarchar(255)  
Declare @WDDest nVarchar(255)  
Declare @CompaniesToUploadCode nVarchar(255) 
Declare @Delimeter  Char(1), @IPrefix as nVarchar(255) ,@IAPrefix as nVarchar(255) 

Set @Delimeter = Char(15)
Create table #tmpAssetID(AssetID int)  

Create table #tempAssetType (AssetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, AssetTypeID int)

Create table #tempAssetNo   (AssetNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempCustomerid (CustomerID nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempCustomerName (CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #tempStatus (Status  nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS )

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
		Insert into #tempAssetType (AssetTypeID) Select Null
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


	insert into #tmpAssetID
	select distinct AssetID From AssetDetail Where DownloadedDate between @FromDate and @ToDate  
    
	select AssetID					  as "AssetID", 
		   @WDCode					  as "WDCode",
		   @WDDest					  as "WD Dest",
           @FromDate				  as "From Date",
		   @ToDate					  as "To Date",
		   AssetNumber				  as "Asset No",
		   AssetType				  as "Asset Type",
		   AssetAbstract.CustomerID   as "Customer ID",	
		   Company_Name				  as "Customer Name",
		   AssetStatus				  as "Current Status"
	From   AssetAbstract,Customer
	Where  AssetAbstract.AssetID in (Select AssetID From #tmpAssetID) And 
		   IsNull(AssetAbstract.AssetTypeID, 0) in (Select IsNull(AssetTypeID, 0)  From #tempAssetType) And
		   AssetAbstract.AssetNumber in (Select  AssetNumber From #tempAssetNo) And
		   AssetAbstract.CustomerID in (Select  CustomerID From #tempCustomerid) And
		   --Customer.Company_Name in (Select CustomerName  From #tempCustomerName) And			
		   AssetAbstract.AssetStatus in (Select Status  From #tempStatus) And
	       AssetAbstract.CustomerId = Customer.Customerid		   
    Order By AssetAbstract.CustomerId
    
	Drop table #tmpAssetID
	Drop table #tempAssetType
	Drop table #tempAssetNo
	Drop table #tempCustomerid
	Drop table #tempCustomerName
	Drop table #tempStatus
End 		   		 	
