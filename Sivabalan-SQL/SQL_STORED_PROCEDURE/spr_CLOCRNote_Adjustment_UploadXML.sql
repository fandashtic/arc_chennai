Create Procedure spr_CLOCRNote_Adjustment_UploadXML (@FromDate Datetime, @ToDate Datetime)
AS
BEGIN
	Set DateFormat DMY
	Declare @DayClosed Int
	Select @DayClosed = 0
	IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
	Begin
		IF ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@ToDate))
			Set @DayClosed = 1
	End

	IF @DayClosed = 0
		GoTo OvernOut
	
	Declare @WDCode NVarchar(255),@WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255)  
	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload          
	Select Top 1 @WDCode = RegisteredOwner From Setup            
	  
	IF @CompaniesToUploadCode='ITC001'          
	Begin          
		Set @WDDest = @WDCode          
	End          
	Else          
	Begin          
		Set @WDDest = @WDCode          
		Set @WDCode = @CompaniesToUploadCode          
	End   
	--For getting Expiry Month
	Declare @Expiry int
	Select @Expiry=isnull(Value,0) from tbl_merp_configdetail where Screencode='SENDRFA' and ControlName='Expiry'
	
	Declare @ManualJournalPrefix nvarchar(50)
	Declare @InvoicePrefix nvarchar(50)
	Declare @StripFromDate Datetime
	Declare @StripToDate Datetime
	Set @StripFromDate = dbo.StripTimeFromDate(@FromDate)
	Set @StripToDate = dbo.StripTimeFromDate(@ToDate)

	Select @ManualJournalPrefix =[Prefix] From [VoucherPrefix] Where [TranID]=N'Manual Journal'
	Select @InvoicePrefix =[Prefix] From [VoucherPrefix] Where [TranID]=N'Invoice'

	Create Table #tmpCLOAdjAbs(CrNtID Int, NoteVal Decimal(18,6), Adjusted Decimal(18,6), Balance Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,RFAClaimed Int)		
	
	Create Table #tmpCLOAdjAbs1(CrNtID Int, NoteVal Decimal(18,6), Adjusted Decimal(18,6), Balance Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,RFAClaimed Int)
		
	Create Table #tmpCLOAdjDet(
	CrNtID Int, AdjType Int, AdjDt DateTime, AdjAmt Decimal(18,6),
	DocumentID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocRef nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AdjTranType nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)
	
	Create Table #tmpCLOAdjTop(CrNtID Int, NoteVal Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,SubmitDt Datetime,RFAClaimed Int)		
	
	Create Table #tmpCLOAdjBot(
	CrNtID Int, AdjType Int, AdjDt DateTime, AdjAmt Decimal(18,6),
	DocumentID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocRef nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AdjTranType nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)
	
	Insert Into #tmpCLOAdjTop (CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID,SubmitDt,RFAClaimed)
	Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID ,@StripToDate, 0
	From CLOCRNote CLO 
	Join CreditNote CR On CR.CreditID = CLO.CreditID And IsNull(CR.Status,0) & 192 = 0  And dbo.StripTimeFromDate(CR.DocumentDate) < = @StripToDate 
	Where IsNull(CLO.IsGenerated,0) = 1 And IsNull(CLO.IsRFAClaimed,0) = 0 And IsNull(CLO.Active,0) = 1 And IsNull(CLO.CreditID,0) > 0
	And (Datediff(d,dateadd(m,@Expiry,dbo.mERP_fn_getToDate(CLOMonth)),@StripToDate)) <= 0
	Union
	Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID , @StripToDate, 0
	From CLOCRNote CLO 
	Join CreditNote CR On CR.CreditID = CLO.CreditID And IsNull(CR.Status,0) & 192 = 0  
	Join tbl_mERP_RFADetail RFADet On RFADet.CSSchemeID = CLO.CreditID
	Join tbl_mERP_RFAAbstract RFAAbs On RFADet.RFAID = RFAAbs.RFAID And RFAAbs.SchemeType = 'GV'  And RFAAbs.SubmissionDate > @StripToDate   	
	Where IsNull(CLO.IsGenerated,0) = 1 And IsNull(CLO.IsRFAClaimed,0) = 1 And IsNull(CLO.Active,0) = 1 And IsNull(CLO.CreditID,0) > 0	
	Union
	Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID , RFAAbs.SubmissionDate, 1
	From CLOCRNote CLO 
	Join CreditNote CR On CR.CreditID = CLO.CreditID And IsNull(CR.Status,0) & 192 = 0  
	Join tbl_mERP_RFADetail RFADet On RFADet.CSSchemeID = CLO.CreditID
	Join tbl_mERP_RFAAbstract RFAAbs On RFADet.RFAID = RFAAbs.RFAID And RFAAbs.SchemeType = 'GV'  And RFAAbs.SubmissionDate Between  @StripFromDate And @StripToDate 
	Where IsNull(CLO.IsGenerated,0) = 1 And IsNull(CLO.IsRFAClaimed,0) = 1 And IsNull(CLO.Active,0) = 1 And IsNull(CLO.CreditID,0) > 0	
	
	--Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID 
	--From CLOCRNote CLO 
	--Join CreditNote CR On CR.CreditID = CLO.CreditID And IsNull(CR.Status,0) & 192 = 0  
	--And dbo.StripTimeFromDate(CR.DocumentDate) Between @StripFromDate And  @StripToDate  
	--Where IsNull(CLO.IsGenerated,0) = 1 And IsNull(CLO.IsRFAClaimed,0) = 1 And IsNull(CLO.Active,0) = 1 And IsNull(CLO.CreditID,0) > 0	
	--Union
	--Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID 
	--From Collections CL
	--Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType in (2,10)
	--Join CreditNote CR On CR.CreditID = CD.DocumentID And IsNull(CR.Status,0) & 192 = 0    
	--Join CLOCRNote CLO On CR.CreditID = CLO.CreditID 
	--Where IsNull(CL.Status,0) & 192= 0 And dbo.StripTimeFromDate(CL.DocumentDate) Between @StripFromDate And  @StripToDate  
	--Union
	--Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID 
	--From GeneralJournal  GJ
	--Join CreditNote CR On CR.CreditID = GJ.DocumentReference  And IsNull(CR.Status,0) & 192 = 0    
	--Join CLOCRNote CLO On CR.CreditID = CLO.CreditID 	
	--Where IsNull(GJ.Status,0) & 192 = 0 And GJ.DocumentType = 35 And dbo.StripTimeFromDate(GJ.TransactionDate)  Between @StripFromDate And  @StripToDate	
	
	--Adj in Collection 
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef,AdjTranType) 
	Select CD.DocumentID , CD.DocumentType ,CL.DocumentDate ,CD.AdjustedAmount ,CL.FullDocID, CL.DocReference, 'Collection'
	From Collections CL
	Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType = 2
	Join #tmpCLOAdjTop CLOAbs On CLOAbs.CrNtID = CD.DocumentID  
	Where IsNull(CL.Status,0) & 192= 0 
	And dbo.StripTimeFromDate(CL.DocumentDate) < = @StripToDate  
	And dbo.StripTimeFromDate(CL.DocumentDate) < = CLOAbs.SubmitDt 
	
	--Adj in Invoice
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef, AdjTranType) 
	Select CD.DocumentID , CD.DocumentType ,CL.DocumentDate ,CD.AdjustedAmount, 
	--@InvoicePrefix + Cast(IA.DocumentID as nvarchar(50)),
	Case IsNULL(IA.GSTFlag ,0)
	When 0 then @InvoicePrefix + Cast(IA.DocumentID as nvarchar(50))
	Else
		IsNULL(IA.GSTFullDocID,'')
	End,
	 IA.DocReference , 'Invoice'
	From Collections CL
	Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType = 10
	Join InvoiceAbstract IA On IA.InvoiceID = CD.InvoiceID 
	Join #tmpCLOAdjTop CLOAbs On CLOAbs.CrNtID = CD.DocumentID  
	Where IsNull(CL.Status,0) & 192= 0 
	And dbo.StripTimeFromDate(CL.DocumentDate) < = @StripToDate  
	And dbo.StripTimeFromDate(CL.DocumentDate) < = CLOAbs.SubmitDt 
	
	--Adj in Manual Journal
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef,AdjTranType) 
	Select GJ.DocumentReference, GJ.DocumentType, GJ.TransactionDate,GJ.Debit, @ManualJournalPrefix + Cast(DocumentNumber as nvarchar(50)), GJ.VoucherNo , 'Manual Journal'
	From GeneralJournal  GJ
	Join #tmpCLOAdjTop CLOAbs On CLOAbs.CrNtID = GJ.DocumentReference 
	Where IsNull(GJ.Status,0) & 192 = 0 And GJ.DocumentType = 35 
	And dbo.StripTimeFromDate(GJ.TransactionDate) < = @StripToDate  
	And dbo.StripTimeFromDate(GJ.TransactionDate) < = CLOAbs.SubmitDt
	
	Insert Into #tmpCLOAdjAbs(CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, Adjusted, Balance,RFAClaimed)
	Select CLOTop.CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, IsNull	(SUM(CLODet.AdjAmt),0), IsNull(NoteVal,0) - IsNull(SUM(CLODet.AdjAmt),0),CLOTop.RFAClaimed
	From #tmpCLOAdjTop CLOTop
	Left Join #tmpCLOAdjBot CLODet On CLODet.CrNtID = CLOTop.CrNtID  
	Group By CLOTop.CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID,RFAClaimed
	
	Insert Into #tmpCLOAdjAbs1 (CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, Adjusted, Balance)
	Select CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, Adjusted, Balance From  #tmpCLOAdjAbs 
	Where RFAClaimed = 0
	Union
	Select CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, Adjusted, Balance From  #tmpCLOAdjAbs 
	Where RFAClaimed = 1 And Adjusted > 0	
	
	Insert Into #tmpCLOAdjDet (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef, AdjTranType) 
	Select CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef, AdjTranType From #tmpCLOAdjBot 
	Where dbo.StripTimeFromDate(AdjDt ) Between @StripFromDate  And @StripToDate  

	/* To Select as XML */
	Declare @RepAbs_ID int
	Declare @CreditID int

	Create Table #XMLData(XMLStr nVarchar(Max))

	Create Table #TmpAbs(RepAbsID Int Identity(1,1), 
	_1   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_2  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	_3   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_4  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	_5   nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,_6  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	_7  nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,_8  nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
	_9  nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS, _10 Decimal(18,6), _11 Decimal(18,6), _12 Decimal(18,6),	_13 Int)--CreditID Int)

	Insert Into #TmpAbs	
	Select "WD Code" = @WDCode, "WD Dest" = @WDDest, "From Date" = @FromDate, "To Date" = @ToDate, 
		"Type" = CLOType, "Month" = CLOMonth, "Ref.Number" = RefNumber, "Customer ID" = CLOA.CustomerID, "Customer Name" = C.Company_Name , 
		CLOA.NoteVal ,  "Adjusted Value" = CLOA.Adjusted , "Balance Value" = CLOA.Balance, CLOA.CrNtID
	From #tmpCLOAdjAbs1 CLOA
	Join Customer C On C.CustomerID = CLOA.CustomerID 
	Where CLOA.Balance > 0	
	Union
	Select "WD Code" = @WDCode, "WD Dest" = @WDDest, "From Date" = @FromDate, "To Date" = @ToDate, 
		"Type" = CLOType, "Month" = CLOMonth, "Ref.Number" = RefNumber, "Customer ID" = CLOA.CustomerID, "Customer Name" = C.Company_Name , 
		CLOA.NoteVal ,  "Adjusted Value" = CLOA.Adjusted , "Balance Value" = CLOA.Balance , CLOA.CrNtID
	From #tmpCLOAdjAbs1 CLOA
	Join (Select Distinct CrNtID  From #tmpCLOAdjDet) CLOD On CLOD.CrNtID = CLOA.CrNtID 
	Join Customer C On C.CustomerID = CLOA.CustomerID 
	Where CLOA.Balance = 0	
	
	Declare XMLCur Cursor FOR Select RepAbsID, _13 From #TmpAbs --CreditID
	Open XMLCur
	Fetch From XMLCur INTO @RepAbs_ID, @CreditID
	While @@Fetch_Status = 0
	Begin
		Insert Into #XMLData (XMLStr)
		Select 
		'Abstract _1="' + ISNULL(_1,'') 
		+ '" _2="' + ISNULL(_2,'') 
		+ '" _3="' + ISNULL(_3,'') 
		+ '" _4="' + ISNULL(_4,'') 
		+ '" _5="' + ISNULL(_5,'') 
		+ '" _6="' + ISNULL(_6,'') 
		+ '" _7="' + ISNULL(_7,'') 
		+ '" _8="' + ISNULL(_8,'') 
		+ '" _9="' + ISNULL(_9,'') 
		+ '" _10="' + Cast(ISNULL(_10,0) as nvarchar) 
		+ '" _11="' + Cast(ISNULL(_11,0) as nvarchar) 		
		+ '" _12="' + Cast(ISNULL(_12,0) as nvarchar) 
		+ '" _13="' + ISNULL(Convert(nVarChar,_13),'') + '"'
		From #TmpAbs	
		Where _13 = @CreditID		--CreditID

		Insert Into #XMLData (XMLStr)
		Select 'Detail _14="' + IsNull(CLOD.AdjTranType  ,'') 
				+ '" _15="' + IsNull(CLOD.DocumentID ,'')
				+ '" _16="' + IsNull(CLOD.DocRef ,'')
				+ '" _17="' + Cast(dbo.StripTimeFromDate(IsNull(CLOD.AdjDt ,'')) as nvarchar(25))
				+ '" _18="' + Cast(IsNull(CLOD.AdjAmt ,0) as nvarchar) 
				+ '" _19="' + IsNull(Convert(nVarChar,CLOD.CrNtID),'')  + '"'
		From #tmpCLOAdjDet CLOD
		Where CLOD.CrNtID = @CreditID
						
		Fetch Next From XMLCur INTO @RepAbs_ID, @CreditID
	End
	Close XMLCur
	Deallocate	XMLCur
	
	Select * From #XMLData as XMLData For XML Auto, Root('Root')	

	Drop Table #TmpAbs
	Drop Table #XMLData
	Drop Table #tmpCLOAdjTop
	Drop Table #tmpCLOAdjBot
	Drop Table #tmpCLOAdjAbs
	Drop Table #tmpCLOAdjAbs1
	Drop Table #tmpCLOAdjDet

OvernOut:
END
