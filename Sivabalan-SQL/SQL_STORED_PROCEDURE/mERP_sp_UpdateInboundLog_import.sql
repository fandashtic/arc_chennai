Create Procedure mERP_sp_UpdateInboundLog_import(@RecCnt Int,@SyncStart Datetime,@SynEnd Datetime)
As
Begin
	EXECUTE AS login = N'itcuser'

Set DateFormat DMY
Insert Into Inbound_Log(ApplicationName, Date, Remarks, NoofOrders, NoofCollections, NoofSalesReturn, NoofAssetTracker,
	SalesmanID, SyncStartTime, SyncEndTime)

Select  'EI' ApName, GetDate() Date, 'ERP - Order Import' Remarks, SOCnt, COLCnt, SRCnt,  AstCnt, 
	SalesmanID, @SyncStart SyncStartDate, @SynEnd SyncEndDate From
(Select SalesmanID, Count(SalesmanID) as SOCnt, 0 COLCnt, 0 as SRCnt, 0 as AstCnt From Order_Header Where isnull(Processed,0) = 0 Group By SalesmanID
Union ALL
Select SalesmanID, 0 as SOCnt, Count(SalesmanID) as COLCnt, 0 as SRCnt, 0 as AstCnt From Collection_Details Where isnull(Processed,0) = 0 Group By SalesmanID
Union ALL
Select SalesmanID, 0 as SOCnt, 0 as COLCnt, Count(SalesmanID) as SRCnt, 0 as AstCnt From Stock_Return Where isnull(Processed,0) = 0 Group By SalesmanID
Union ALL
Select DSID as SalesmanID, 0 as SOCnt, 0 as COLCnt, 0 as SRCnt, Count(DSID) as AstCnt From AssetInfoTracking_HH Where isnull(Status,0) = 0 Group By DSID
) A

/*
	Insert Into Inbound_Log(ApplicationName,Date,Remarks,NoOfOrders,NoOfCollections,NoOfSalesReturn,
							SyncStartTime,SyncEndTime)
	Values('EI',GetDate(),'ERP - Order Import',@RecCnt,0,0,@SyncStart,@SynEnd)
*/
End
