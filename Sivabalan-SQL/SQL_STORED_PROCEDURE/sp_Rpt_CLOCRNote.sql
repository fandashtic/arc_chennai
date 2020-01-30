Create PROCEDURE sp_Rpt_CLOCRNote(@ParmMonth as nVarchar(25))
AS    

	Declare @WDCode NVarchar(255)  
	Declare @WDDest NVarchar(255)  
	Declare @CompaniesToUploadCode NVarchar(255) 

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
		    
	IF @CompaniesToUploadCode='ITC001'    
		Set @WDDest= @WDCode    
	Else    
	Begin    
		Set @WDDest= @WDCode    
		Set @WDCode= @CompaniesToUploadCode    
	End 

	Create Table #TmpCLOCRNote(CLOType nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS, CLOMonth nvarchar(16)COLLATE SQL_Latin1_General_CP1_CI_AS,
					CustomerID nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS, RefNumber nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
					Amount Decimal(18,6), ISGenerated int, BalanceAmount Decimal(18,6), Status nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
					ReportUploadDate Datetime, CreditID int)		

	Insert Into #TmpCLOCRNote(CLOType, CLOMonth, CustomerID, RefNumber, Amount, ISGenerated, ReportUploadDate, CreditID)
	Select CLCR.CLOType , CLCR.CLOMonth , CLCR.CustomerID, 
	CLCR.RefNumber, CLCR.Amount , IsGenerated, GetDate(), CreditID
	From CLOCrNote CLCR
	Where CLCR.CLOMonth='Jun-2016' and CLCR.CLOType='RedeemFC_AprMay'

	Update CLCR Set CLCR.BalanceAmount = isnull(CR.Balance,0), 
	CLCR.Status = Case When (isnull(CR.Status,0) & 64) <> 0 Then 'Cancelled'
					When isnull(CR.Status,0) = 0 and isnull(CR.Balance,0) > 0 Then 'Open'
					When isnull(CR.Status,0) = 0 and isnull(CR.Balance,0) = 0 Then 'Closed' End				
	From #TmpCLOCRNote CLCR, CreditNote CR
	Where isnull(CLCR.CreditID, 0) = CR.CreditID

	Update #TmpCLOCRNote Set BalanceAmount = 0, Status = 'Deactivated' Where isnull(IsGenerated,0) = 0

	Select CreditID, @WDCode [WDCode], @WDDest [WDDest], CLOType [Type], CLOMonth [Month], CustomerID [OutletID],
		RefNumber [RefNo], Amount, BalanceAmount, Status, 
		(Convert(varchar(10), ReportUploadDate, 103)+ ' ' + Convert(varchar(10),ReportUploadDate, 108)) [ReportUploadDate] 
	From #TmpCLOCRNote

	Drop Table #TmpCLOCRNote
