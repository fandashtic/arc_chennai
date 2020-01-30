CREATE PROCEDURE sp_tmptbl_VAlloc_ImportData
AS  
Begin
Select	'If object_id(''tempdb..#tmpImportData'') is not null ' + CHAR(10) + CHAR(13) +
		'	Drop table #tmpImportData ' + CHAR(10) + CHAR(13) +
		'
		CREATE TABLE #tmpImportData(
		ID Int Identity(1,1),
		CustID nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CustName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		GSTFullDocID nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		DocNo nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		InvDate nVarChar(10),
		InvVal Decimal(18,6),
		Salesman nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Beat nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Zone nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Van nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		VADate nVarChar(10),
		SeqNo Int,
		ShipmentNo Int,
		ErrorMsg nVarChar(2000),
		InvoiceID Int,	
		Status Int,		
		OrgDocNo nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OrgInvDate nVarChar(10),
		OrgInvVal Decimal(18,6),
		OrgStatus Int,
		OrgCustID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OrgSalesman nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OrgBeat nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		OrgZone nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SalesManID Int,
		BeatID Int,
		ZoneID Int,
		OrgVan nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		VanNumber nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
		CheckInvDate DateTime,
		CheckVanDate DateTime,
		DSActive Int,
		BeatActive Int,
		ZoneActive Int,
		VanActive Int
		)'
End
