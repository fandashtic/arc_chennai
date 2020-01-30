Create Procedure Sp_GetNULLDS
AS
BEGIN
		Set DateFormat DMY
		Declare @DaycloseDate DateTime
		
		Select @DaycloseDate=dbo.StripDateFromTime(isnull(LastInventoryUpload,GETDATE())) From Setup

		--IF Exists(Select 'x' From Inbound_Log Where isnull(SalesmanID, 0) = 0 and dbo.StripDateFromTime(Date)>@DaycloseDate)		

		Select * into #tmpSalesman From 
		(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>@DaycloseDate and isnull(Processed,0)=0
		Union All
		--Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>@DaycloseDate and isnull(Processed,0)=0
		Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
		Union All
		Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>@DaycloseDate and isnull(Processed,0)=0
		Union All
		Select Distinct DSID as SalesmanID From AssetInfoTracking_HH Where dbo.StripDateFromTime(DownloadedDate)>@DaycloseDate and isnull(Status,0)=0) T

		Select Distinct SalesmanID From #tmpSalesman

		Drop Table #tmpSalesman
END
