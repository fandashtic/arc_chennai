CREATE PROCEDURE sp_get_InvoicesforVanMap
(         
    @FromDate DateTime,
	@ToDate	DateTime,
	@SalesMan NVarChar(4000) = N'',
	@Beat NVarChar(4000) = N'',	
	@Zone NVarChar(4000) = N''
)
AS  
Begin

Set DateFormat DMY

Create Table #TblSalesman(SalesManID Int)
Create Table #TblBeat(BeatID Int)
Create Table #TblZone(ZoneID Int)

If @SalesMan = N''
	Begin
		Insert InTo #TblSalesman Values(0)
		Insert InTo #TblSalesman Select SalesmanID From SalesMan --Where Active = 1
	End
Else
	Insert InTo #TblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',') 

If @Beat = N''	
	Begin
		Insert InTo #TblBeat Values(0)
		Insert InTo #TblBeat Select BeatID From Beat --Where Active = 1
	End
Else
	Insert InTo #TblBeat Select * From sp_SplitIn2Rows(@Beat,N',')


If @Zone = N''	
	Begin
		Insert InTo #TblZone Values(0)
		Insert InTo #TblZone Select ZoneID From tbl_merp_Zone --Where Active = 1
	End
Else
	Begin
		Insert InTo #TblZone Values(0)
		Insert InTo #TblZone Select * From sp_SplitIn2Rows(@Zone,N',')
	End
	
Select IA.* Into #tmpInvoiceAbstract
From InvoiceAbstract IA
Inner Join #TblSalesman LS On LS.SalesmanID = IA.SalesManID
Inner Join #TblBeat LB On LB.BeatID = IA.BeatID 
Where (IA.InvoiceType = 1 Or Ia.InvoiceType = 3)
	And	dbo.StripTimeFromDate(InvoiceDate) Between @FromDate And @ToDate
	And	(IsNull(IA.Status,0) & 128) = 0
	And	(IsNull(IA.Status,0) & 16) = 0

Select
	"Invoice Date" = dbo.StripTimeFromDate(IA.InvoiceDate),
	"Customer ID" = IA.CustomerID,
	"Customer Name" = C.Company_Name,
	"Doc ID" = IA.GSTFullDocID ,
	"Doc No" = IA.DocReference,
	"Amount" = IsNull(IA.NetValue,0) + IsNull(IA.RoundOffAmount,0) ,
	"DS Name" = S.Salesman_Name ,
	"Beat" = B.Description ,
	"Zone" = IsNull((Select IsNull(ZoneName,'') From tbl_mERP_Zone Where ZoneID = C.ZoneID),'') ,
	"InvoiceID" = IA.InvoiceID
   ,"GSTDocID" = IA.GSTDocID , "SalesManID" = IA.SalesManID, "BeatID" = IA.BeatID, "ZoneID" = IsNull(C.ZoneID,0)
From 
	#tmpInvoiceAbstract IA
	Inner Join Customer C On IA.CustomerID = C.CustomerID 
	Inner Join Salesman S On IA.SalesmanID = S.SalesmanID 
	Inner Join #TblSalesman LS On LS.SalesmanID = S.SalesManID 
	Inner Join Beat B On IA.BeatID = B.BeatID 
	Inner Join #TblBeat LB On LB.BeatID = B.BeatID 
	Inner Join #TblZone LZ On LZ.ZoneID = IsNull(C.ZoneID,0)
Where (IA.InvoiceType = 1 Or Ia.InvoiceType = 3)
	And	dbo.StripTimeFromDate(InvoiceDate) Between @FromDate And @ToDate
	And	(IsNull(Status,0) & 128) = 0
	And	(IsNull(Status,0) & 16) = 0
	Order by dbo.StripTimeFromDate(IA.InvoiceDate),IA.GSTFullDocID

Drop Table #TblSalesman
Drop Table #TblBeat
Drop Table #TblZone
Drop Table #tmpInvoiceAbstract
End
