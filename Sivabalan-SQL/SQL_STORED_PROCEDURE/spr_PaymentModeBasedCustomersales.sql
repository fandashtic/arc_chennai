CREATE PROCEDURE [dbo].[spr_PaymentModeBasedCustomersales]( @FROMDATE datetime,                
       @TODATE datetime,                
       @DocType nvarchar(100),
	   @Term Nvarchar(255) = '%')                
                
AS                
Begin
	DECLARE @INV AS NVARCHAR(50)                
	DECLARE @CASH AS NVARCHAR(50)    
	DECLARE @CREDIT AS NVARCHAR(50)                
	DECLARE @CHEQUE AS NVARCHAR(50)    
	DECLARE @DD AS NVARCHAR(50)    
	SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)    

	SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)   
	SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)    
	SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)    
	SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'                
	Declare @Payid as Int
	Create Table #Term(PaymentId Int)

	CREATE TABLE #Tempid(
		[Id] [int] NOT NULL,
		[InvoiceID] [nvarchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Date] [datetime] NULL,
		[CustomerID] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Customer] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Net Value] [decimal](18, 6) NULL,
		[Adjusted Amount] [decimal](18, 6) NULL,
		[Round Off] [decimal](18, 6) NULL,
		[Beat] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Salesman] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Document Type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Doc Ref] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Payment Mode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CashAmount  [decimal](18, 6) NULL,
		CreditAmount  [decimal](18, 6) NULL
	) ON [PRIMARY]

	Truncate Table #Term

	 if @term = 'Credit'
		Begin
			Truncate Table #Term
			Insert Into #Term Select 0
		End
	 Else if @term  = 'Cash'
		Begin
			Truncate Table #Term
			Insert Into #Term Select 1
		End
	 Else if @term  = 'Cheque'	
		Begin
			Truncate Table #Term
			Insert Into #Term Select 2
		End
	 Else if @term  = 'DD'	
		Begin
			Truncate Table #Term
			Insert Into #Term Select 3
		End
	Else IF @term = '%'
		Begin
			Truncate Table #Term
			Insert Into #Term Select 0
			Insert Into #Term Select 1

			Insert Into #Term Select 2
			Insert Into #Term Select 3
		End

	Insert into #Tempid
	SELECT  InvoiceID Id,                 
	"InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR),    
	"Date" = InvoiceDate,         
	"CustomerID" = Customer.CustomerID,  
               
	"Customer" = Customer.Company_Name,                
	"Net Value" = NetValue,   
	"Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),                
	"Round Off" = RoundOffAmount,                
	"Beat" = Beat.Description,    
            
	"Salesman" = Salesman.Salesman_Name,   
	"Document Type" = DocSerialType,                    
	"Doc Ref" = InvoiceAbstract.DocReference,                
	"Payment Mode" = case IsNull(PaymentMode,0)                
	 When 0 Then @Credit      
          
	 When 1 Then @Cash                
	 When 2 Then @Cheque        
	 When 3 Then @DD                
	 Else @Credit                
	 End,
	0,0
	FROM InvoiceAbstract with (nolock)
	Join Customer with (nolock) ON Customer.CustomerID = InvoiceAbstract.CustomerID
	Left Join Salesman with (nolock) ON Salesman.SalesManId = InvoiceAbstract.SalesmanID
	Left Join Beat with (nolock) ON Beat.BeatID = InvoiceAbstract.BeatID
--	FROM InvoiceAbstract, Customer, Beat, Salesman                 
	WHERE  InvoiceType in (1,3) AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND                
	 --InvoiceAbstract.CustomerID = Customer.CustomerID AND                
	 --InvoiceAbstract.BeatID = Beat.BeatID And                
	 --InvoiceAbstract.SalesmanID = Salesman.SalesmanID And                 
	 (InvoiceAbstract.Status & 128) = 0 And                
	 InvoiceAbstract.DocSerialType like @DocType             
	and paymentMode  in (select Distinct PaymentId from #Term)
	Order By  DocumentID    

	Update T set T.CashAmount = T1.NetAmount From  #tempid T,
	(SELECT InvoiceID , (IsNull(InvoiceAbstract.AdjustedAmount, 0) + RoundOffAmount  + NetValue) NetAmount
--	FROM InvoiceAbstract, Customer, Beat, Salesman                 
	FROM InvoiceAbstract with (nolock)
	Join Customer with (nolock) ON Customer.CustomerID = InvoiceAbstract.CustomerID
	Left Join Salesman with (nolock) ON Salesman.SalesManId = InvoiceAbstract.SalesmanID
	Left Join Beat with (nolock) ON Beat.BeatID = InvoiceAbstract.BeatID

	WHERE  InvoiceType in (1,3) AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND                
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND                
	 --InvoiceAbstract.BeatID *= Beat.BeatID And                
	 --InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And                 
	 (InvoiceAbstract.Status & 128) = 0 And                
	 InvoiceAbstract.DocSerialType like @DocType             
	and paymentMode  in (select Distinct PaymentId from #Term)) T1
	Where T.id = T1.InvoiceID and T.[payment Mode]  = 'Cash
'
	 
	Update T set T.CreditAmount = T1.NetAmount From  #tempid T,
	(SELECT InvoiceID , (IsNull(InvoiceAbstract.AdjustedAmount, 0) + RoundOffAmount  + NetValue) NetAmount
	--FROM InvoiceAbstract, Customer, Beat, Salesman                 
	FROM InvoiceAbstract with (nolock)
	Join Customer with (nolock) ON Customer.CustomerID = InvoiceAbstract.CustomerID
	Left Join Salesman with (nolock) ON Salesman.SalesManId = InvoiceAbstract.SalesmanID
	Left Join Beat with (nolock) ON Beat.BeatID = InvoiceAbstract.BeatID
	WHERE  InvoiceType in (1,3) AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND                
	 InvoiceAbstract.CustomerID = Customer.CustomerID AND                
	 --InvoiceAbstract.BeatID *= Beat.BeatID And                
	 --InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And                 
	 (InvoiceAbstract.Status & 128) = 0 And                
	 InvoiceAbstract.DocSerialType like @DocType             
	and paymentMode  in (select Distinct PaymentId from #Term)) T1
	Where T.id = T1.InvoiceID and T.[payment Mode]  = 'Credit'

	--Update #tempid set CashAmount = [Net Value] Where [payment Mode] = 'Credit'

	select * from #tempid  Order By [payment Mode] Asc
	Drop Table #Term
	Drop table #tempid
END
