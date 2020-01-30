Create Procedure spr_CLOCRNote_Adjustment_Detail (@CreditID int, @FromDate Datetime, @ToDate Datetime)
AS
BEGIN	
	Set DateFormat DMY
	Declare @ManualJournalPrefix nvarchar(50)
	Declare @InvoicePrefix nvarchar(50)

	Declare @StripFromDate Datetime
	Declare @StripToDate Datetime
	Set @StripFromDate = dbo.StripTimeFromDate(@FromDate)
	Set @StripToDate = dbo.StripTimeFromDate(@ToDate)

	Select @ManualJournalPrefix =[Prefix] From [VoucherPrefix] Where [TranID]=N'Manual Journal'
	Select @InvoicePrefix =[Prefix] From [VoucherPrefix] Where [TranID]=N'Invoice'

	Create Table #tmpCLOAdjBot(
	CrNtID Int, AdjType Int, AdjDt DateTime, AdjAmt Decimal(18,6),
	DocumentID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocRef nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AdjTranType nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @RFAClaim Int
	Declare @SubmitDt DateTime
	If (Select IsNull(IsRFAClaimed,0) From CLOCrNote Where CreditID = @CreditID) = 0
		Set @SubmitDt = @StripToDate 	
	Else
		If Exists (Select 'x' From tbl_mERP_RFAAbstract RFAAbs
		Join tbl_mERP_RFADetail RFADet  On RFADet.RFAID = RFAAbs.RFAID And RFAAbs.SchemeType = 'GV'  
		And RFADet.CSSchemeID = @CreditID And RFAAbs.SubmissionDate > @StripToDate)		
			Set @SubmitDt = @StripToDate
		Else		
			Select @SubmitDt = SubmissionDate From tbl_mERP_RFAAbstract RFAAbs
			Join tbl_mERP_RFADetail RFADet  On RFADet.RFAID = RFAAbs.RFAID And RFAAbs.SchemeType = 'GV'
			And RFADet.CSSchemeID = @CreditID And RFAAbs.SubmissionDate Between @StripFromDate And @StripToDate 					
	
	If @SubmitDt Is Null 
		Set @SubmitDt = @StripToDate 
	
	--Adj in Collection 
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef,AdjTranType) 
	Select CD.DocumentID , CD.DocumentType ,CL.DocumentDate ,CD.AdjustedAmount ,CL.FullDocID, CL.DocReference, 'Collection'
	From Collections CL
	Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType = 2 And CD.DocumentID = @CreditID
	Where IsNull(CL.Status,0) & 192= 0 
	And dbo.StripTimeFromDate(CL.DocumentDate) < =  @SubmitDt
	And dbo.StripTimeFromDate(CL.DocumentDate) Between @StripFromDate and @StripToDate 
	
	--Adj in Invoice
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef, AdjTranType) 
	Select CD.DocumentID , CD.DocumentType ,CL.DocumentDate ,CD.AdjustedAmount,
--	@InvoicePrefix + Cast(IA.DocumentID as nvarchar(50)), 
	Case IsNULL(IA.GSTFlag ,0)
	When 0 then @InvoicePrefix + Cast(IA.DocumentID as nvarchar(50))
	Else
		IsNULL(IA.GSTFullDocID,'')
	End,
	IA.DocReference , 'Invoice'
	From Collections CL
	Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType = 10 And CD.DocumentID = @CreditID
	Join InvoiceAbstract IA On IA.InvoiceID = CD.InvoiceID	
	Where IsNull(CL.Status,0) & 192= 0 
	And dbo.StripTimeFromDate(CL.DocumentDate) < =  @SubmitDt
	And dbo.StripTimeFromDate(CL.DocumentDate) Between @StripFromDate and @StripToDate 
	
	--Adj in Manual Journal
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt, DocumentID, DocRef,AdjTranType) 
	Select GJ.DocumentReference, GJ.DocumentType, GJ.TransactionDate,GJ.Debit, @ManualJournalPrefix + Cast(DocumentNumber as nvarchar(50)), GJ.VoucherNo , 'Manual Journal'
	From GeneralJournal  GJ	
	Where IsNull(GJ.Status,0) & 192 = 0 And GJ.DocumentType = 35 And GJ.DocumentReference = @CreditID
	And dbo.StripTimeFromDate(GJ.TransactionDate) < =  @SubmitDt
	And dbo.StripTimeFromDate(GJ.TransactionDate)  Between @StripFromDate and @StripToDate 

	Select Det.CrNtID, "Document Type" = Det.AdjTranType, "SL.No." = Det.DocumentID , "Document ID" = Det.DocRef , 
	"Document Date" = Det.AdjDt,	"Adjustment Value" = Det.AdjAmt 	From #tmpCLOAdjBot Det

	Drop Table #tmpCLOAdjBot

END
