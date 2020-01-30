Create Procedure spr_CLOCRNote_Adjustment_Abstract (@FromDate Datetime, @ToDate Datetime)
AS
BEGIN
	Set DateFormat DMY
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

	Declare @StripFromDate Datetime
	Declare @StripToDate Datetime
	Set @StripFromDate = dbo.StripTimeFromDate(@FromDate)
	Set @StripToDate = dbo.StripTimeFromDate(@ToDate)

	Create Table #tmpCLOAdjAbs(CrNtID Int, NoteVal Decimal(18,6), Adjusted Decimal(18,6), Balance Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,RFAClaimed Int)	
	
	Create Table #tmpCLOAdjAbs1(CrNtID Int, NoteVal Decimal(18,6), Adjusted Decimal(18,6), Balance Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,RFAClaimed Int)	

	Create Table #tmpCLOAdjDet(CrNtID Int, AdjType Int, AdjDt DateTime, AdjAmt Decimal(18,6))
	
	Create Table #tmpCLOAdjTop(CrNtID Int, NoteVal Decimal(18,6), CurBal Decimal(18,6),
	CLOType nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RefNumber nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,SubmitDt Datetime,RFAClaimed Int)		
	
	Create Table #tmpCLOAdjBot(CrNtID Int, AdjType Int, AdjDt DateTime, AdjAmt Decimal(18,6))
	
	Insert Into #tmpCLOAdjTop (CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, SubmitDt,RFAClaimed)
	Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID , @StripToDate, 0
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
	--Union
	--Select Distinct CLO.CreditID, CLO.Amount, CR.Balance, CLO.CLOType, CLO.CLOMonth, CLO.RefNumber, CR.CustomerID 
	--From CLOCRNote CLO 
	--Join CreditNote CR On CR.CreditID = CLO.CreditID And IsNull(CR.Status,0) & 192 = 0  
	--And dbo.StripTimeFromDate(CR.DocumentDate) Between @StripFromDate And  @StripToDate  
	--Where IsNull(CLO.IsGenerated,0) = 1 And IsNull(CLO.IsRFAClaimed,0) = 1 And IsNull(CLO.Active,0) = 1 And IsNull(CLO.CreditID,0) > 0	
	
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt ) 
	Select CD.DocumentID , CD.DocumentType ,CL.DocumentDate ,CD.AdjustedAmount 
	From Collections CL 
	Join CollectionDetail CD On CD.CollectionID = CL.DocumentID And CD.DocumentType in (2,10) 
	Join #tmpCLOAdjTop CLOAbs On CLOAbs.CrNtID = CD.DocumentID   
	Where IsNull(CL.Status,0) & 192= 0 
	And dbo.StripTimeFromDate(CL.DocumentDate) < = @StripToDate 
	And dbo.StripTimeFromDate(CL.DocumentDate) < = CLOAbs.SubmitDt 
	
	Insert Into #tmpCLOAdjBot (CrNtID ,AdjType ,AdjDt ,AdjAmt ) 	
	Select GJ.DocumentReference, GJ.DocumentType, GJ.TransactionDate,GJ.Debit 
	From GeneralJournal  GJ
	Join #tmpCLOAdjTop CLOAbs On CLOAbs.CrNtID = GJ.DocumentReference 
	Where IsNull(GJ.Status,0) & 192 = 0 And GJ.DocumentType = 35 
	And dbo.StripTimeFromDate(GJ.TransactionDate) < = @StripToDate  
	And dbo.StripTimeFromDate(GJ.TransactionDate) < = CLOAbs.SubmitDt
	
	Insert Into #tmpCLOAdjAbs(CrNtID, NoteVal ,CurBal, CLOType, CLOMonth, RefNumber, CustomerID, Adjusted, Balance,RFAClaimed )
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
	
	Insert Into #tmpCLOAdjDet (CrNtID ,AdjType ,AdjDt ,AdjAmt ) 	
	Select CrNtID ,AdjType ,AdjDt ,AdjAmt  From #tmpCLOAdjBot Where dbo.StripTimeFromDate(AdjDt ) Between @StripFromDate  And @StripToDate  
	
	Select CLOA.CrNtID, "WD Code" = @WDCode, "WD Dest" = @WDDest, "From Date" = @FromDate, "To Date" = @ToDate, 
		"Type" = CLOType, "Month" = CLOMonth, "Ref.Number" = RefNumber, "Customer ID" = CLOA.CustomerID, "Customer Name" = C.Company_Name , 
		CLOA.NoteVal ,  "Adjusted Value" = CLOA.Adjusted , "Balance Value" = CLOA.Balance 
	From #tmpCLOAdjAbs1 CLOA
	Join Customer C On C.CustomerID = CLOA.CustomerID 
	Where CLOA.Balance > 0
	Union
	Select CLOA.CrNtID, "WD Code" = @WDCode, "WD Dest" = @WDDest, "From Date" = @FromDate, "To Date" = @ToDate, 
		"Type" = CLOType, "Month" = CLOMonth, "Ref.Number" = RefNumber, "Customer ID" = CLOA.CustomerID, "Customer Name" = C.Company_Name , 
		CLOA.NoteVal ,  "Adjusted Value" = CLOA.Adjusted , "Balance Value" = CLOA.Balance 
	From #tmpCLOAdjAbs1  CLOA
	Join (Select Distinct CrNtID  From #tmpCLOAdjDet) CLOD On CLOD.CrNtID = CLOA.CrNtID 
	Join Customer C On C.CustomerID = CLOA.CustomerID 
	Where CLOA.Balance = 0	

	Drop Table #tmpCLOAdjTop
	Drop Table #tmpCLOAdjBot
	Drop Table #tmpCLOAdjAbs
	Drop Table #tmpCLOAdjAbs1
	Drop Table #tmpCLOAdjDet
END
