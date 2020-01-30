Create Procedure Sp_CheckLogforNULLDS
AS
BEGIN
		Set Dateformat DMY
		Declare @DaycloseDate DateTime
		Select @DaycloseDate=dbo.StripDateFromTime(isnull(LastInventoryUpload,GETDATE())) From Setup
		Select * into #tmpData From 
		(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
		Union All
		--Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
		Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
		Union All
		Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
		Union All
		Select Distinct DSID as SalesmanID From AssetInfoTracking_HH Where dbo.StripDateFromTime(DownloadedDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Status,0)=0) T
		
		if(select COUNT(*) from #tmpData)>0
		BEGIN
			If (select COUNT(*) from Inbound_Log where SalesmanID is null and dbo.StripDateFromTime([date])>@DaycloseDate)>=1
				Select 1
			else
				Select 0
		END
		Else
		BEGIN
			Select 0
		END
		Drop Table #tmpData
END
