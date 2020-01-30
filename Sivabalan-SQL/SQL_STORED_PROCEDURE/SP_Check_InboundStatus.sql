Create Procedure SP_Check_InboundStatus(@ProcessIDs nvarchar(4000))
As
BEGIN
Set Dateformat DMY
Declare @DaycloseDate DateTime
Select @DaycloseDate=dbo.StripDateFromTime(isnull(LastInventoryUpload,GETDATE())) From Setup

Create Table #tmpProcess(ProcessID Int)
Insert Into #tmpProcess(ProcessID)
Select itemvalue from dbo.sp_SplitIn2Rows(@ProcessIDs,',')

Create Table #tmpSalesMans(SalesManID Int)
Insert Into #tmpSalesMans(SalesManID )
Select SalesmanID From Inbound_Status Where ProcessID In (Select ProcessID from #tmpProcess)

Create Table #tmpResults(Flag Int,ProcessID Int,SalesManID Int)

/* NEW SYNC */
If (Select COUNT(*) from Inbound_Status
Where ISNULL([status],0)=0 and dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans))>=1
Begin
Insert Into #tmpResults (Flag ,ProcessID ,SalesManID)
Select 1,LogID,SalesmanID From Inbound_Status
where ISNULL([Status],0)=0 And dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans)
Order by LogID
End
/* ABORTED SYNC*/
Else If (Select COUNT(*) from Inbound_Status
where ISNULL([status],0)=1 and dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
And processid not in (Select ProcessID from #tmpProcess)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans))>0
Begin
Insert Into #tmpResults (Flag ,ProcessID ,SalesManID)
Select 2,LogID,SalesmanID From Inbound_Status
where ISNULL([status],0)=1 and dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
and ProcessID Not In (Select ProcessID from #tmpProcess)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans)
Order by LogID
End
/* INCOMPLETE SYNC*/
Else If (Select COUNT(*) from Inbound_Status
where ISNULL([status],0)=2 and dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
And ProcessID Not In (Select ProcessID from #tmpProcess)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans)
And SalesmanID in
(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Union All
--		Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
Union All
Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Union All
Select Distinct DSID as SalesmanID From AssetInfoTracking_HH Where dbo.StripDateFromTime(DownloadedDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Status,0)=0))>0
Begin
Insert Into #tmpResults (Flag ,ProcessID ,SalesManID)
Select 2,LogID,SalesmanID From Inbound_Status where ISNULL([status],0)=2 and dbo.StripDateFromTime(DaycloseDate)>=dbo.StripDateFromTime(@DaycloseDate)
And ProcessID Not In (Select ProcessID from #tmpProcess)
And SalesmanID Not In (Select Distinct SalesmanID From #tmpSalesMans)
And SalesmanID in
(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Union All
--		Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
Union All
Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Processed,0)=0
Union All
Select Distinct DSID as SalesmanID From AssetInfoTracking_HH Where dbo.StripDateFromTime(DownloadedDate)>dbo.StripDateFromTime(@DaycloseDate) and isnull(Status,0)=0)
Order by LogID
End
Else If (Select Count(*) From (Select Distinct SalesmanID From
(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>@DaycloseDate and isnull(Processed,0)=0
Union All
--Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>@DaycloseDate and isnull(Processed,0)=0
Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
Union All
Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>@DaycloseDate and isnull(Processed,0)=0
Union All
Select Distinct DSID as SalesmanID From AssetInfoTracking_HH
Where dbo.StripDateFromTime(DownloadedDate)>@DaycloseDate And isnull(Status,0)=0) S
Where S.SalesManID Not In (Select Distinct SalesmanID From #tmpSalesMans)) T) > 0
Begin
Insert Into #tmpResults (Flag ,ProcessID ,SalesManID)
Select 3,-1,T.SalesmanID From (Select Distinct S.SalesManID From
(Select Distinct SalesmanID From Order_Header Where dbo.StripDateFromTime(Order_DATE)>@DaycloseDate and isnull(Processed,0)=0
Union All
--Select Distinct SalesmanID From Collection_details Where dbo.StripDateFromTime(CollectionDate)>@DaycloseDate and isnull(Processed,0)=0
Select Distinct SalesmanID From Collection_details Where isnull(Processed,0)=0
Union All
Select Distinct SalesmanID From Stock_Return Where dbo.StripDateFromTime(DocumentDate)>@DaycloseDate and isnull(Processed,0)=0
Union All
Select Distinct DSID as SalesmanID From AssetInfoTracking_HH
Where dbo.StripDateFromTime(DownloadedDate)>@DaycloseDate and isnull(Status,0)=0) S
Where S.SalesManID Not In (Select Distinct SalesmanID From #tmpSalesMans)) T
Order by T.SalesManID
End
--Else

If Exists(Select 'x' From #tmpResults)
Begin
Select Flag=Max(R.Flag), ProcessID=Min(R.ProcessID), R.SalesManID From #tmpResults R Group By R.SalesManID
End
Else
BEGIN
Update Inbound_Status Set Status=2 where Status=1 and processid not in (Select ProcessID from #tmpProcess)
Select 0,-1,-1
END
Drop Table #tmpProcess
Drop Table #tmpSalesMans
Drop Table #tmpResults
END
