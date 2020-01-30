Create procedure merp_spr_giftvoucher_detail (@GVNo Int, @UnUsedFD DateTime, @UnUsedTD DateTime)  
as 
Begin 
	Declare @Prefix nVarchar(50)  
	Declare @GVPrefix nVarchar(50)  
	Declare @CLPrefix nVarchar(50)  
	Declare @MJPrefix nVarchar(50)  
	select @Prefix = Prefix from voucherprefix Where TranID = 'Invoice'  
	select @GVPrefix = Prefix from voucherprefix Where TranID = 'GIFT VOUCHER'
	select @CLPrefix = Prefix from voucherprefix Where TranID = 'COLLECTIONS'
	select @MJPrefix = Prefix from VoucherPrefix where [TranID]=N'MANUAL JOURNAL'   

	Create Table #Temp (ID Nvarchar(255),
		[Invoice ID] Nvarchar(255),
		[Document Reference] Nvarchar(255),
		[Invoice Date] Nvarchar(255),
		[Invoice Value] Decimal(18,6),
		[Adjustment Value] Decimal(18,6),
		Balance Decimal(18,6))

	Create Table #TempOut (ID Int Identity(1,1),
		[Document ID] Nvarchar(255),
		[Document Reference] Nvarchar(255),
		[Document Date] Nvarchar(255),
		[Document Value] Decimal(18,6),
		[Adjustment Value] Decimal(18,6),
		Balance Decimal(18,6))

	Insert into #Temp
	Select ia.InvoiceID,   
	'Invoice ID' = @Prefix + Cast(ia.DocumentID as nVarchar(20)),  
	'Document Reference' = ia.DocReference,  
	'Invoice Date' = Convert(Varchar(10),ia.InvoiceDate,103 ),  
	'Invoice Value' = ia.NetValue,  
	'Adjustment Value' = sum(cd.AdjustedAmount),  
	'Balance' =  Max(CD.DocumentValue) -  (Select Sum(CD1.AdjustedAMount)   
	 From CollectionDetail CD1, InvoiceAbstract IA1, CreditNote Cn1  
	 Where CD1.OriginalID = Cn1.DocumentReference
	 and cn1.DocumentID = @GVNo  
	 and IA1.InvoiceID = CD1.InvoiceID   
	 and IA1.Status & 128 = 0   
	 and IsNull(cn1.status,0) & 128 = 0  
	 and IA1.InvoiceID <= IA.InvoiceID)  
	from CollectionDetail cd, collections col, InvoiceAbstract ia, creditnote cn  
	Where cd.InvoiceID = ia.InvoiceID  
	And cd.collectionid = col.documentId 
	And CD.DocumentID=CN.CreditID
	--And cd.DocumentType = 10  
	And cd.OriginalID = @GVPrefix + Cast(cn.DocumentID As nVarchar) 
	And Isnull(cn.Flag,0) in(1,2)  
	And IsNull(ia.status, 0) & 128 = 0  
	And IsNull(cn.status,0) & 128 = 0  
	And IsNull(col.status, 0) <> 192  
	And cn.DocumentID = @GVNo  
	
	Group by   
	ia.InvoiceID, @Prefix + Cast(ia.DocumentID as nVarchar(20)),ia.DocReference,Convert(Varchar(10),ia.InvoiceDate,103 ), ia.NetValue  
	Order By ia.InvoiceID,Convert(Varchar(10),ia.InvoiceDate,103 )

/* For Collection */

	Insert Into #Temp
	Select Distinct Cd.CollectionID,   
	'Invoice ID' = Cast(col.FullDocID as nVarchar(20)),  
	'Document Reference' = col.DocReference,  
	'Invoice Date' = Convert(Varchar(10),col.DocumentDate,103 ),  
	'Invoice Value' = cd.AdjustedAmount,  
	'Adjustment Value' = cd.AdjustedAmount,  
	'Balance' =  CR.NoteValue - cd.AdjustedAmount
	from CollectionDetail cd, collections col, creditnote CR
	Where cd.collectionid = col.documentId 
	And IsNull(col.status, 0) not in (192,128)
	And cd.OriginalID = @GVPrefix + Cast(@GVNo As nVarchar) 
	And isnull(cd.InvoiceID,0) = 0
	And CR.DocumentID = @GVNo 
	And CD.Documentid=CR.CreditID


/* For Manual Juornal */

	Insert Into #Temp
	Select Distinct cast(GJ.DocumentNumber as Nvarchar(255)),   
	'Invoice ID' = @MJPrefix + Cast(Gj.DocumentNumber as nVarchar(20)),  
	'Document Reference' = Gj.DocumentReference,
	'Invoice Date' = Convert(Varchar(10),Gj.TransactionDate,103 ),  
	'Invoice Value' = GJ.Debit,  
	'Adjustment Value' =GJ.Debit,  
	'Balance' =  GJ.Debit - GJ.Debit
	from creditnote CR, Generaljournal GJ,Customer C
	Where CR.DocumentID = @GVNo
	And GJ.DocumentReference=CR.CreditID
	--And GJ.accountid = 926
	and (isnull(GJ.[Status],0)<>128 and isnull(GJ.[Status],0)<>192) and GJ.[DocumentType] in (26,35,37)
	And GJ.AccountID = C.AccountID
	And C.CustomerID = CR.CustomerID

	Insert Into #TempOut
	Select [Invoice ID],[Document Reference],[Invoice Date],[Invoice Value],[Adjustment Value],Balance From  #Temp Order By [Invoice Date] 

	Declare @ID as int
	Declare @Adj as Decimal(18,6)
	Declare @GVValue as Decimal(18,6)
	Declare @TmpGVValue as Decimal(18,6)

	Set @GVValue = (Select Top 1 Isnull(NoteValue,0) from creditnote	Where DocumentID = @GVNo)

	Set @TmpGVValue = @GVValue

	Declare Cur Cursor For
	Select ID,Isnull([Adjustment Value],0) From #TempOut 
	Open cur
	Fetch From cur into @id,@Adj
	While @@fetch_status = 0
	Begin
		Set @TmpGVValue = @TmpGVValue - @Adj
		Update #TempOut Set Balance = @TmpGVValue Where ID = @ID
				
		Fetch Next From cur into @id,@Adj
	End
	Close cur
	Deallocate cur

	Select * from #TempOut

	Drop Table #Temp
	Drop Table #TempOut
End
