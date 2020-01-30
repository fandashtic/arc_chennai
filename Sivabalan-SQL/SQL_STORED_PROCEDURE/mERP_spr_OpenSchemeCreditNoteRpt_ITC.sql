CREATE PROCEDURE mERP_spr_OpenSchemeCreditNoteRpt_ITC
(
    @FROMDATE datetime,      
	@TODATE datetime, 
	@SHOW nVarChar(20)
)      
As

Declare @Delimeter as Char(1)            
Set @Delimeter=Char(15)

Declare @PCR As nVarchar(5)  
Declare @PINV As nVarchar(5)   
Declare @CRID As nVarchar(50) 
Declare @DocID nVarchar(50)
Declare @DocRef nVarchar(50)
Declare @InvDate nVarchar(50)
Declare @Counter Int
Declare @CDocID nVarchar(Max)
Declare @CDocRef nVarchar(Max)
Declare @CInvDate nVarchar(Max)	
Declare @CustId nvarchar(15) 

Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Declare @PGV As nVarchar(5) 

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload        
Select Top 1 @WDCode = RegisteredOwner From Setup          

If @CompaniesToUploadCode='ITC001'        
Begin        
 Set @WDDest= @WDCode        
End        
Else        
Begin        
 Set @WDDest = @WDCode        
 Set @WDCode = @CompaniesToUploadCode        
End 

Select @PCR = Prefix From VoucherPrefix
Where TranID = 'CREDIT NOTE' 

Select @PGV = Prefix From VoucherPrefix 
Where TranID = 'GIFT VOUCHER' 

--Select * From VoucherPrefix

Select @PINV = Prefix From VoucherPrefix Where TranID Like 'MANUAL JOURNAL'

Create Table #Temp1 (IDs Int Identity(1, 1), 	
	[Customer Id] nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Customer Name] nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Channel Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Loyalty Program] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[WD Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[WD Dest] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[From Date] Datetime, [To Date] Datetime, 
	[Credit Note ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Credit Note Reference] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Activity Code] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Central Scheme ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Scheme Name] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Payout Period From] Datetime, 
	[Payout Period To] Datetime, 
	[Credit Note Value] Decimal(18, 6), 
	[Amount Adjusted] Decimal(18, 6), 
	[Adj. Doc Number] nVarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Adj. Doc Ref Number] nVarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Adj. Doc Date] nVarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	[Balance Amount] Decimal(18, 6) 
)

Insert InTo #Temp1
Select "Customer ID" =crn.customerid ,
	"Customer Name" =isNull(C.Company_Name,''),
	"Channel Type" =isNull(OLC.Channel_Type_Desc,''),
	"Outlet Type" =isNull(OLC.Outlet_Type_Desc,'') ,
	"Loyalty Program" = isNull(OLC.SubOutlet_Type_Desc,''),	
	"WD Code" = @WDCode, "WD Dest" = @WDDest, "From Date" = @FROMDATE, "To Date" = @TODATE, 
	"Credit Note ID" = @PCR + Cast(crn.DocumentID As nVarchar), "Credit Note Reference" = crn.DocumentReference, 
	"Activity Code" = sa.ActivityCode, "Central Scheme ID" = sa.CS_RecSchID, 
	"Scheme Name" = sa.Description, "Payout Period From" = spp.PayoutperiodFrom, 
	"Payout Period To" = spp.PayoutPeriodto, "Credit Note Value" = crn.NoteValue, 
	"Amount Adjusted" = (crn.NoteValue - crn.Balance), 
	"Adj. Doc Number" = Case When crn.Balance <> crn.NoteValue Then '1' Else '' End, 
	"Adj. Doc Ref Number" = '', 
	"Adj. Doc Date" = '', 
	"Balance Amount" = crn.Balance 
From CreditNote crn, tbl_mERP_SchemePayoutPeriod spp, tbl_mERP_SchemeAbstract sa, 
	Customer C,tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM
Where crn.PayoutID = spp.ID And spp.SchemeID = sa.SchemeID 
And	crn.Balance = Case @SHOW When 'All' Then crn.Balance 
							 When 'Adjusted' Then 0 
							 When 'Not Adjusted' Then (Select Balance From CreditNote crn1 
								Where crn1.CreditID = crn.CreditID And crn1.Balance > 0) End 
	And IsNull(crn.Status, 0) & 192 = 0 And crn.DocumentDate Between @FROMDATE and @TODATE 
    And IsNull(Flag,0) = 1 
	And C.CustomerId=crn.CustomerId
	and OLM.CustomerID = c.CustomerID
	And OLM.OLClassID = OLC.ID
	And OLM.Active = 1 
Order By crn.DocumentID, sa.ActivityCode 

-- Gift Voucher Credit Note == 
Insert InTo #Temp1 
Select "Customer ID" = crn.customerid, "Customer Name" = isNull(C.Company_Name,''), 
	"Channel Type" = isNull(OLC.Channel_Type_Desc,''), 
	"Outlet Type" = isNull(OLC.Outlet_Type_Desc,''), 
	"Loyalty Program" = isNull(OLC.SubOutlet_Type_Desc,''), 
	"WD Code" = @WDCode, "WD Dest" = @WDDest, 
	"From Date" = @FROMDATE, "To Date" = @TODATE, 
	"Credit Note ID" = @PGV + Cast(crn.DocumentID As nVarchar), 
	"Credit Note Reference" = crn.DocumentReference, 
	"Activity Code" = ly.LoyaltyName + '-' + Substring(DateName(MM, crn.DocumentDate), 1, 3) + '-' + DateName(YYYY, crn.DocumentDate), 
	"Central Scheme ID" = '', 
	"Scheme Name" = ly.LoyaltyName + '-' + Substring(DateName(MM, crn.DocumentDate), 1, 3) + '-' + DateName(YYYY, crn.DocumentDate), 
	"Payout Period From" = Cast('01/' + Cast(DatePart(MM, crn.DocumentDate) As nVarchar) + '/' + Cast(DatePart(YYYY, crn.DocumentDate) As nVarchar) As Datetime), 
	"Payout Period To" = DateAdd(D, -1, DateAdd(MM, 1, Cast('01/' + Cast(DatePart(MM, crn.DocumentDate) As nVarchar) + '/' + Cast(DatePart(YYYY, crn.DocumentDate) As nVarchar) As Datetime))), 
	"Credit Note Value" = crn.NoteValue, 
	"Amount Adjusted" = (crn.NoteValue - crn.Balance),
	"Adj. Doc Number" = Case When crn.Balance <> crn.NoteValue Then '1' Else '' End,  
	"Adj. Doc Ref Number" = '', 
	"Adj. Doc Date" = '', 
	"Balance Amount" = crn.Balance 
From CreditNote crn, Customer C, tbl_mERP_OLClass OLC, Loyalty ly, tbl_mERP_OLClassMapping OLM
Where crn.Balance = Case @SHOW When 'All' Then crn.Balance 
							 When 'Adjusted' Then 0 
							 When 'Not Adjusted' Then (Select Balance From CreditNote crn1 
								Where crn1.CreditID = crn.CreditID And crn1.Balance > 0) End 
	And IsNull(crn.Status, 0) & 192 = 0 
	And crn.DocumentDate Between @FROMDATE and @TODATE 
    And IsNull(Flag,0) = 2 
	And C.CustomerId=crn.CustomerId
	and OLM.CustomerID = c.CustomerID
	And OLM.OLClassID = OLC.ID
	And OLM.Active = 1 
	And crn.LoyaltyID = ly.LoyaltyID 
	And crn.CreditID Not In (Select CreditID From CLOCrNote) 
Order By crn.DocumentID  

--===
-- CLO Credit Note == 
Insert InTo #Temp1 
Select "Customer ID" = crn.customerid, "Customer Name" = isNull(C.Company_Name,''), 
	"Channel Type" = isNull(OLC.Channel_Type_Desc,''), 
	"Outlet Type" = isNull(OLC.Outlet_Type_Desc,''), 
	"Loyalty Program" = isNull(OLC.SubOutlet_Type_Desc,''), 
	"WD Code" = @WDCode, "WD Dest" = @WDDest, 
	"From Date" = @FROMDATE, "To Date" = @TODATE, 
	"Credit Note ID" = @PGV + Cast(crn.DocumentID As nVarchar), 
	"Credit Note Reference" = clo.RefNumber, 
	"Activity Code" = clo.CLOType + '-' + Substring(DateName(MM, clo.CLODate), 1, 3) + '-' + DateName(YYYY, clo.CLODate), 
	"Central Scheme ID" = '', 
	"Scheme Name" = clo.CLOType + '-' + Substring(DateName(MM, clo.CLODate), 1, 3) + '-' + DateName(YYYY, clo.CLODate), 
	"Payout Period From" = clo.CLODate, 
	"Payout Period To" = DateAdd(D, -1, DateAdd(MM, 1, clo.CLODate)), 
	"Credit Note Value" = crn.NoteValue, 
	"Amount Adjusted" = (crn.NoteValue - crn.Balance),
	"Adj. Doc Number" = Case When crn.Balance <> crn.NoteValue Then '1' Else '' End,  
	"Adj. Doc Ref Number" = '', 
	"Adj. Doc Date" = '', 
	"Balance Amount" = crn.Balance 
From CreditNote crn, Customer C, tbl_mERP_OLClass OLC, 
	Loyalty ly, tbl_mERP_OLClassMapping OLM, CLOCrNote clo 
Where crn.Balance = Case @SHOW When 'All' Then crn.Balance 
							 When 'Adjusted' Then 0 
							 When 'Not Adjusted' Then (Select Balance From CreditNote crn1 
								Where crn1.CreditID = crn.CreditID And crn1.Balance > 0) End 
	And IsNull(crn.Status, 0) & 192 = 0 
	And crn.DocumentDate Between @FROMDATE and @TODATE 
    And IsNull(Flag,0) = 1 
	And C.CustomerId=crn.CustomerId
	and OLM.CustomerID = c.CustomerID
	And OLM.OLClassID = OLC.ID
	And OLM.Active = 1 
	And crn.LoyaltyID = ly.LoyaltyID 
	And crn.CreditID = clo.CreditID 
Order By crn.DocumentID  

--===

Declare CRDtl Cursor For
	Select Distinct [Credit Note ID],[customer id] From #Temp1 
	Where [Adj. Doc Number] = '1' 
Open CRDtl
Fetch Next From CRDtl InTo @CRID ,@CustId
While @@Fetch_Status = 0 
Begin
	Set @Counter = 1 
	Declare InvDtl Cursor For 
    Select ColDet.OriginalID, IsNull(InvAbs.DocReference,''), Convert(nvarchar(10),ColDet.DocumentDate,103)
    from InvoiceAbstract InvAbs, CollectionDetail  ColDet
    Where InvAbs.InvoiceID = ColDet.DocumentID and 
    IsNull(InvAbs.Status, 0) & 192 = 0 and
    InvAbs.CustomerID = @CustId and 
    ColDet.DocumentType = 4 and 
    ColDet.CollectionId in (Select CollectionID from CollectionDetail Where OriginalId = @CRID)
    Union
    Select ColDet.OriginalID, IsNull(DbN.DocumentReference,''), Convert(nvarchar(10),ColDet.DocumentDate,103)
    from DebitNote DbN, CollectionDetail  ColDet
    Where DbN.DebitID = ColDet.DocumentID and 
    IsNull(DbN.Status, 0) & 64 = 0 and
    DbN.CustomerID = @CustId and
    ColDet.DocumentType = 5 and 
    ColDet.CollectionId in (Select CollectionID from CollectionDetail Where OriginalId = @CRID)
    Union
    Select @PINV + Cast(DocumentNumber as nVarchar(15)), N'' as DocumentReference, Convert(nvarchar(10),TransactionDate,103)
    from GeneralJournal J, Customer c 
    Where c.customerid=@custId and c.AccountId=J.AccountID and 
	isnull(J.status,0) <> 128 and isnull(J.status,0) <> 192 and J.DocumentType = 37 and 
    J.DocumentReference = 2 and 
    --dbo.StripTimeFromDate(TransactionDate) >= @FROMDATE and
    J.DocumentNumber in(Select GJ.DocumentNumber From GeneralJournal GJ, CreditNote CrN, Customer C
      Where C.CustomerID = CrN.CustomerID and 
      CrN.CreditID = GJ.DocumentReference and 
      C.AccountID = GJ.AccountID and 
      GJ.DocumentType in (35,37) and 
      CrN.DocumentReference = @CRID and 
      C.CustomerID = @CustId) 

	Open InvDtl
	Fetch From InvDtl InTo @DocID, @DocRef, @InvDate
	While @@Fetch_Status = 0        
	Begin        
		If @Counter = 1
		Begin
			Set @CDocID = @DocID
			Set @CDocRef = @DocRef
			Set @CInvDate = @InvDate 
		End
		Else
		Begin
			Set @CDocID = @CDocID + ', ' + @DocID
			Set @CDocRef = @CDocRef + ', ' + @DocRef
			Set @CInvDate = @CInvDate + ', ' + @InvDate
		End
		Set @Counter = 0 
	  Fetch Next From InvDtl InTo @DocID, @DocRef, @InvDate
	End 


	Update #Temp1 Set [Adj. Doc Number] = @CDocID, 
		[Adj. Doc Ref Number] = @CDocRef, 
		[Adj. Doc Date] = @CInvDate 
	Where [Credit Note ID] = @CRID and [Customer Id] = @CustID

	Close InvDtl
	Deallocate InvDtl

	Fetch Next From CRDtl InTo @CRID ,@CustId
End

Close CRDtl
Deallocate CRDtl

	

Select Distinct [WD Code],[WD Code],[WD Dest] , [From Date] , [To Date] ,[Customer Id],[Customer Name],[Channel Type],[Outlet Type],[Loyalty Program], [Credit Note ID] , [Credit Note Reference] , [Activity Code] ,  [Central Scheme ID] ,  [Scheme Name] ,  [Payout Period From] , [Payout Period To] , [Credit Note Value] , [Amount Adjusted] , [Adj. Doc Number] ,  [Adj. Doc Ref Number],  [Adj. Doc Date] ,  [Balance Amount]   From #Temp1 Order By [Customer Id]

Drop Table #Temp1 	
