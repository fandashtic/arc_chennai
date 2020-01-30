CREATE PROCEDURE sp_Validate_VAlloc_ImportData
(
    @UserName nVarChar(50),
    @OperatingYear nVarChar(10)
)
AS  
Begin

--Code For Debug--Start
--CREATE TABLE #tmpImportData(
--ID Int Identity(1,1),
--CustID nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CustName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--GSTFullDocID nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--DocNo nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--InvDate nVarChar(10),
--InvVal Decimal(18,6),
--Salesman nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--Beat nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--Zone nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--Van nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--VADate nVarChar(10),
--SeqNo Int,
--ShipmentNo Int,
--ErrorMsg nVarChar(2000),
--InvoiceID Int,	
--Status Int,		
--OrgDocNo nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--OrgInvDate nVarChar(10),
--OrgInvVal Decimal(18,6),
--OrgStatus Int,
--OrgCustID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
--OrgSalesman nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--OrgBeat nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--OrgZone nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--SalesManID Int,
--BeatID Int,
--ZoneID Int,
--OrgVan nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--VanNumber nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CheckInvDate DateTime,
--CheckVanDate DateTime,
--DSActive Int,
--BeatActive Int,
--ZoneActive Int,
--VanActive Int
--)
--	Insert into #tmpImportData 
--	(CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
--	ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate)
--	Select 
--	CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
--	ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
--	From tmpVAImportRawData
--	Select * from #tmpImportData
--Code For Debug--End

 Set DateFormat DMY
 
 --Declare @UserName nVarChar(50)
 --Set @UserName = 'Sify'
 
 Declare @DefaultVan nVarChar(50)
 Declare @Van nVarChar(50)
 Declare @VanNum nVarChar(50)
 Declare @VADate DateTime
 Declare @ShipmentNo Int
 
 Declare @VAllocID Int
 Declare @DOCUMENTID Int
 Declare @FullDocID nVarChar(255)
 Declare @GSTVoucherPrefix nvarchar(10)
 
 Declare @GenVASlips Int
 Set @GenVASlips = 0
 
 Declare @OpenDt DateTime
 Select @OpenDt = OpeningDate From Setup 
	
 If object_id('tempdb..#tmpImportData') Is Not Null
  Begin

	If object_id('tmpVAImportRawData') Is Not Null
		Drop Table tmpVAImportRawData	
	
	Select * Into tmpVAImportRawData From #tmpImportData
		
	Update #tmpImportData Set ErrorMsg = '' , Status = 0
	
	If object_id('tempdb..#tmpErrImportData') Is Not Null
		Drop Table #tmpErrImportData
		
	CREATE TABLE #tmpErrImportData(
		ID Int,
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
		)
	
	If object_id('tempdb..#tmpInvAbs') Is Not Null
		Drop Table #tmpInvAbs	

	Select * Into #tmpInvAbs from InvoiceAbstract Where InvoiceType in (1,3)
	
	Set @DefaultVan = ''
	Select Top 1 @DefaultVan = IsNull(VAN,'') from VehicleAllocationVan Order by CreationDate Desc
	
	Update ID Set InvoiceID = IA.InvoiceID, OrgDocNo = IA.DocReference , OrgInvDate = CONVERT(nVarChar(10),IA.InvoiceDate,103), OrgCustID = IA.CustomerID,
				  OrgStatus = IsNull(IA.Status,0), OrgSalesman = S.Salesman_Name, OrgBeat = B.Description , OrgZone = IsNull(Z.ZoneName,'')
				  ,SalesManID = S.SalesmanID, BeatID = B.BeatID, ZoneID= IsNull(Z.ZoneID,0) , DSActive = S.Active , BeatActive = B.Active , ZoneActive = Z.Active 
				  ,VADate = Case When VADate = ''  Then CONVERT(nVarChar(10),GETDATE(),103) Else VADate End, OrgInvVal = IsNull(NetValue,0) + ISNULL(RoundOffAmount,0) 
	From #tmpImportData ID 
	Inner Join #tmpInvAbs IA On IA.GSTFullDocID = ID.GSTFullDocID
	Inner Join Customer C On IA.CustomerID = C.CustomerID
	Inner Join Salesman S On IA.SalesmanID = S.SalesmanID
	Inner Join Beat B On IA.BeatID = B.BeatID
	Left Outer Join tbl_mERP_Zone Z On Z.ZoneID = IsNull(C.ZoneID,0)
	Where IA.Status & 192 = 0 And IA.Status & 16 = 0
	
	Update #tmpImportData Set Van = @DefaultVan Where IsNull(Van,'') = ''
	Update ID Set OrgVan  = V.Van, VanNumber = V.Van_Number, VanActive = V.Active From #tmpImportData ID Inner Join Van V On V.Van = ID.Van

	Update ID Set ErrorMsg = ErrorMsg + 'Amened/Canceled Bill Number.', ID.Status = ID.Status | 1
	From #tmpImportData ID 
	Inner Join #tmpInvAbs IA On IA.GSTFullDocID = ID.GSTFullDocID
	Where IA.Status & 192 <> 0 And IsNull(ID.InvoiceID,0) <=0

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive, SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData Where Status & 1 <> 0

	Update ID Set ErrorMsg = ErrorMsg + 'Van Invoice not allowed to Import.', ID.Status = ID.Status | 1
	From #tmpImportData ID 
	Inner Join #tmpInvAbs IA On IA.GSTFullDocID = ID.GSTFullDocID
	Where IA.Status & 192 = 0 And IA.Status & 16 <> 0  And IsNull(ID.InvoiceID,0) <=0

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData  Where Status & 1 <> 0	
	
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Invalid Bill Number.', Status = Status | 1 Where IsNull(InvoiceID,0) <=0
	
	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData  Where Status & 1 <> 0	
	
	Update ID Set ID.ErrorMsg = ErrorMsg + 'Bill Number More than one time not allowed in single import file.', ID.Status = ID.Status | 1
	From #tmpImportData ID 
	Inner Join (Select GSTFullDocID From #tmpImportData Group By GSTFullDocID Having Count(*) > 1) ID2 On ID2.GSTFullDocID = ID.GSTFullDocID

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData  Where Status & 1 <> 0	
		
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Incorrect Date Format in Invoice Date. Required Date format [DD/MM/YYYY].' , Status = Status | 1
	--Where IsDate(InvDate) = 0	

	Update #tmpImportData Set CheckInvDate = Convert(DateTime , OrgInvDate) Where IsDate(OrgInvDate) = 1
	
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Invoice Date must be greater than [' + CONVERT(nVarChar(10),@OpenDt,103) + ']'
	, Status = Status | 1
	Where CheckInvDate Is Not Null And CheckInvDate < @OpenDt
	
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Incorrect Date Format in Van Date. Required Date format [DD/MM/YYYY].' , Status = Status | 1
	Where IsDate(VADate) = 0
	
	Update #tmpImportData Set CheckVanDate = Convert(DateTime , VADate) Where IsDate(VADate) = 1
	
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Van Date must be greater than [' + CONVERT(nVarChar(10),@OpenDt,103) + '].'
	, Status = Status | 1
	Where CheckVanDate Is Not Null And CheckVanDate < @OpenDt

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData Where Status & 1 <> 0	
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Doc No. not found.' , Status = Status | 1 Where IsNull(DocNo,'') = ''
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Invoice Date not found.' , Status = Status | 1 Where IsNull(InvDate,'') = ''
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Salesman not found.' , Status = Status | 1 Where IsNull(Salesman,'') = ''
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Beat not found.' , Status = Status | 1 Where IsNull(Beat,'') = ''

	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Default Van not found.' , Status = Status | 1 Where IsNull(Van,'') = ''

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData Where Status & 1 <> 0	

	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Doc No. not matched.' , Status = Status | 1 Where IsNull(DocNo,'') <> IsNull(OrgDocNo,'')
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Invoice Date not matched.' , Status = Status | 1 Where IsNull(InvDate,'')  <> IsNull(OrgInvDate,'')
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Salesman not matched.' , Status = Status | 1 Where IsNull(Salesman,'') <> IsNull(OrgSalesman,'')
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Beat not matched.' , Status = Status | 1 Where IsNull(Beat,'') <> IsNull(OrgBeat,'')
	
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Zone not matched.' , Status = Status | 1 Where IsNull(Zone,'') <> IsNull(OrgZone,'')
	
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Van Name not matched.' , Status = Status | 1 Where IsNull(Van,'') <> IsNull(OrgVan,'')
	
	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData Where Status & 1 <> 0

	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Inactive Salesman assginged.' , Status = Status | 1 Where DSActive = 0
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Inactive Beat assginged.' , Status = Status | 1 Where BeatActive = 0
	--Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Inactive Beat assginged.' , Status = Status | 1 Where ZoneActive = 0
	Update #tmpImportData Set ErrorMsg = ErrorMsg + 'Inactive Van assginged.' , Status = Status | 1 Where VanActive = 0

	Insert Into #tmpErrImportData
	(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
	Select 
	ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
	From #tmpImportData ID Where Status & 1 <> 0
	
	Delete From #tmpImportData Where Status & 1 <> 0
	
	--Seq No Validation
	If (Select SUM(IsNull(ShipmentNo,0)) From #tmpImportData) > 0
	  Begin
		Declare VASlip Cursor for Select Van, VanNumber, CheckVanDate, ShipmentNo from #tmpImportData Group By Van, VanNumber,CheckVanDate, ShipmentNo
		Open VASlip
		Fetch From VASlip Into @Van, @VanNum, @VADate, @ShipmentNo
		While @@FETCH_STATUS = 0
		Begin
			If (Select SUM(IsNull(SeqNo,0)) From #tmpImportData  
				Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate And ShipmentNo = @ShipmentNo ) > 0
			Begin
				If object_id('tempdb..#tmpSeqValidate1') is not null
					Drop Table #tmpSeqValidate1
				
				Create Table #tmpSeqValidate1 ( SeqID Int Identity(1,1),SeqNo Int,MinSeqNo Int,NewSeqNo Int,ID Int)
				
				Declare @MinSeqNo1 Int
				Set @MinSeqNo1 = 0
				Select @MinSeqNo1 =Min(SeqNo)-1 
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate And ShipmentNo = @ShipmentNo 

				Insert Into #tmpSeqValidate1 (SeqNo,MinSeqNo,ID)
				Select SeqNo, @MinSeqNo1 ,ID
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate And ShipmentNo = @ShipmentNo 
					Order By SeqNo
					
				Update #tmpSeqValidate1 Set NewSeqNo = SeqNo - MinSeqNo 
				
				Update ID Set ID.ErrorMsg = ID.ErrorMsg + 'Invalid Sequence number.' , ID.Status = ID.Status | 1 
				From #tmpImportData ID Inner Join #tmpSeqValidate1 SV On SV.ID = ID.ID And SV.SeqID <> SV.NewSeqNo
				
				Insert Into #tmpErrImportData
				(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
					ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
					,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
				Select 
				ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
					ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
					,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
				From #tmpImportData ID Where Status & 1 <> 0
				
				Delete From #tmpImportData Where Status & 1 <> 0				
				
			End
			
			Fetch Next From VASlip Into @Van, @VanNum, @VADate, @ShipmentNo
		End
		Close VASlip
		DeAllocate VASlip	   
	  End
	 Else
	  Begin	
		Declare VASlip Cursor for Select Van, VanNumber, CheckVanDate from #tmpImportData Group By Van, VanNumber, CheckVanDate
		Open VASlip
		Fetch From VASlip Into @Van, @VanNum, @VADate
		While @@FETCH_STATUS = 0
		Begin
			If (Select SUM(IsNull(SeqNo,0)) From #tmpImportData
				Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate) > 0
			Begin
				If object_id('tempdb..#tmpSeqValidate2') is not null
					Drop Table #tmpSeqValidate2
				
				Create Table #tmpSeqValidate2 ( SeqID Int Identity(1,1),SeqNo Int,MinSeqNo Int,NewSeqNo Int,ID Int)

				Declare @MinSeqNo2 Int
				Set @MinSeqNo2 = 0
				Select @MinSeqNo2 =Min(SeqNo)-1 
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate
				
				Insert Into #tmpSeqValidate2 (SeqNo,MinSeqNo,ID)
				Select SeqNo, @MinSeqNo2 ,ID
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate
					Order By SeqNo
					
				Update #tmpSeqValidate2 Set NewSeqNo = SeqNo - MinSeqNo 
				
				Update ID Set ID.ErrorMsg = ID.ErrorMsg + 'Invalid Sequence number.' , ID.Status = ID.Status | 1 
				From #tmpImportData ID Inner Join #tmpSeqValidate2 SV On SV.ID = ID.ID And SV.SeqID <> SV.NewSeqNo
				
				Insert Into #tmpErrImportData
				(ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
					ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
					,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID)
				Select 
				ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
					ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
					,DSActive , BeatActive ,ZoneActive ,VanActive , SalesManID, BeatID, ZoneID
				From #tmpImportData ID Where Status & 1 <> 0
				
				Delete From #tmpImportData Where Status & 1 <> 0				
				
			End
						
			Fetch Next From VASlip Into @Van, @VanNum, @VADate
		End
		Close VASlip
		DeAllocate VASlip
	  End
	  
	--Trace import data--Start
	If object_id('tmpVAImportData') Is Not Null
		Drop Table tmpVAImportData		

	Select ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate
		,DSActive , BeatActive ,ZoneActive ,VanActive, SalesManID, BeatID, ZoneID  Into tmpVAImportData
	From #tmpImportData
	
	If object_id('tmpErrVAImportData') Is Not Null
		Drop Table tmpErrVAImportData		

	Select ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,
		ErrorMsg,InvoiceID,Status,OrgDocNo,OrgInvDate,OrgStatus,OrgSalesman,OrgBeat,OrgZone,OrgVan,CheckInvDate,CheckVanDate 
		,DSActive , BeatActive ,ZoneActive ,VanActive, SalesManID, BeatID, ZoneID Into tmpErrVAImportData
	From #tmpErrImportData 
	--Trace import data--Start
	
	IF Not Exists(Select 'x' From #tmpErrImportData)
	Begin
	 If (Select SUM(IsNull(ShipmentNo,0)) From #tmpImportData) > 0
	  Begin
		Declare VASlip Cursor for Select Van, VanNumber, CheckVanDate, ShipmentNo from #tmpImportData Group By Van, VanNumber,CheckVanDate, ShipmentNo
		Open VASlip
		Fetch From VASlip Into @Van, @VanNum, @VADate, @ShipmentNo
		While @@FETCH_STATUS = 0
		Begin			
			BEGIN TRAN
					UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 108
					Select @DOCUMENTID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 108
					Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'VEHICLE ALLOCATION'
					Select @FullDocID = @GSTVoucherPrefix + Cast(@DOCUMENTID as nvarchar(50))
			COMMIT TRAN  

			Insert Into VAllocAbstract 
			(DocumentID, FullDocID, AllocDate, Van, VanNumber, GenType, OperatingYear, UserName, ShipmentNo) Values
			(@DOCUMENTID, @FullDocID, @VADate, @Van, @VanNum, 2, @OperatingYear, @UserName,@ShipmentNo)

			Select @VAllocID = @@IDENTITY 
			IF IsNull(@VAllocID,0) > 0
			Begin
				Insert Into VAllocDetail
				(VAllocID,InvoiceID,InvoiceDate,CustomerID,GSTDocID,GSTFullDocID,DocReference,InvoiceValue,SalesmanID,BeatID,ZoneID,SequenceNo) 
				Select 
				@VAllocID,InvoiceID,CheckInvDate,OrgCustID,0,GSTFullDocID,OrgDocNo,OrgInvVal, SalesManID, BeatID, ZoneID, SeqNo
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate And ShipmentNo = @ShipmentNo
			End
			
			Set @GenVASlips = @GenVASlips + 1
			
			Fetch Next From VASlip Into @Van, @VanNum, @VADate, @ShipmentNo
		End
		Close VASlip
		DeAllocate VASlip	   
	  End
	 Else
	  Begin	
		Declare VASlip Cursor for Select Van, VanNumber, CheckVanDate from #tmpImportData Group By Van, VanNumber, CheckVanDate
		Open VASlip
		Fetch From VASlip Into @Van, @VanNum, @VADate
		While @@FETCH_STATUS = 0
		Begin			
			BEGIN TRAN
					UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 108
					Select @DOCUMENTID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 108
					Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'VEHICLE ALLOCATION'
					Select @FullDocID = @GSTVoucherPrefix + Cast(@DOCUMENTID as nvarchar(50))
			COMMIT TRAN  

			Insert Into VAllocAbstract 
			(DocumentID, FullDocID, AllocDate, Van, VanNumber, GenType, OperatingYear, UserName) Values
			(@DOCUMENTID, @FullDocID, @VADate, @Van, @VanNum, 2, @OperatingYear, @UserName)

			Select @VAllocID = @@IDENTITY 
			IF IsNull(@VAllocID,0) > 0
			Begin
				Insert Into VAllocDetail
				(VAllocID,InvoiceID,InvoiceDate,CustomerID,GSTDocID,GSTFullDocID,DocReference,InvoiceValue,SalesmanID,BeatID,ZoneID,SequenceNo) 
				Select 
				@VAllocID,InvoiceID,CheckInvDate,OrgCustID,0,GSTFullDocID,OrgDocNo,OrgInvVal, SalesManID, BeatID, ZoneID, SeqNo
					From #tmpImportData Where Van = @Van And VanNumber = @VanNum And CheckVanDate = @VADate 
			End
			
			Set @GenVASlips = @GenVASlips + 1
			
			Fetch Next From VASlip Into @Van, @VanNum, @VADate
		End
		Close VASlip
		DeAllocate VASlip
	  End
	  
	  Select 1,CONVERT(nVarChar,@GenVASlips) + ' Van Allocation slip(s) Generated Successfully.'
	End
	Else
	Begin
		Select -1, 'Error found in importing data.'
		--Select ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,ErrorMsg From #tmpImportData 
		--Union 
		Select ID,CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo,ErrorMsg From #tmpErrImportData
		--Order by ID	
	End
	
	If object_id('tempdb..#tmpImportData') is not null
		Drop Table #tmpImportData
		
	If object_id('tempdb..#tmpErrImportData') is not null
		Drop Table #tmpErrImportData	
		
	If object_id('tempdb..#tmpInvAbs') Is Not Null
		Drop Table #tmpInvAbs
		
	If object_id('tempdb..#tmpSeqValidate1') is not null
		Drop Table #tmpSeqValidate1

	If object_id('tempdb..#tmpSeqValidate2') is not null
		Drop Table #tmpSeqValidate2
	
  End	
 Else
  Begin
	Select -2,'Unable to validate import data.'
  End
End
