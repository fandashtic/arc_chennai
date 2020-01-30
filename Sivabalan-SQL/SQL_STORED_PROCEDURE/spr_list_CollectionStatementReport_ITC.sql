CREATE procedure spr_list_CollectionStatementReport_ITC(@SalesmanID nVarchar(255) ,@Fromdate Datetime,
@Todate Datetime,@PaymentMode nVarchar(50),@CollectionMode nvarchar(2550))
As
Declare @Delimeter as nChar(1) 
Set @Delimeter=Char(15) 

--CollectionStatement Temp table
Create table #tmpCollectionStatement (
DocumentID int,
CollectionMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Paymode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CollectionDate Datetime,
CollectionID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
CollectionReference nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CollectionSalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocumentType nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--DocDate Datetime,
DocDate nVarchar(25),
CustomerID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesmanID int,
SalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
HandHeldDS nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
InvoiceAmount Decimal(18,6),
AmountReceived Decimal(18,6),
AddlAdjustment Decimal(18,6),
ExtraCollection Decimal(18,6),
TotalCollection Decimal(18,6),
Balance Decimal(18,6),
Cheque_DDNumber  int,
--Cheque_DDDate Datetime,
Cheque_DDDate nVarchar(25),
Bank nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Branch nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
)


--Salesman Temp Table
Create table #tmpSalesMan(SalesManId int) 

if @SalesmanID=N'%'     
Begin 
   Insert into #tmpSalesMan select SalesmanId from SalesMan    
End
Else    
   Insert into #tmpSalesMan Select SalesmanId From SalesMan Where SalesMan_Name In(select * from dbo.sp_SplitIn2Rows(@SalesmanID,@Delimeter))    



--Paymentmode Temp Table

Create Table #TmpPaymode(paymode int)                        
Create Table #TmpPayMode2(paymode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, pid int)

Insert Into #TmpPayMode2 Values (N'Cash', 0)  
Insert Into #TmpPayMode2 Values (N'Cheque', 1)  
Insert Into #TmpPayMode2 Values (N'DD', 2)  
Insert Into #TmpPayMode2 Values (N'Credit Card', 3)  
Insert Into #TmpPayMode2 Values (N'Bank Transfer', 4)
Insert Into #TmpPayMode2 Values (N'Coupon', 5)  
  

if  @PaymentMode = '%'              
     Insert into #TmpPaymode select pid from #TmpPayMode2
else              
	 Insert into #TmpPaymode Select Pid From #TmpPayMode2 
		Where paymode in (select * from dbo.sp_SplitIn2Rows( @PaymentMode, @Delimeter))	

--CollectionMode Temp Table 

Create Table #TmpCollectionmode(collmode int)                        
Create Table #TmpCollectionmode2(collmode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Cid int)

Insert Into #TmpCollectionmode2 Values (N'Normal Collection', 0)  
Insert Into #TmpCollectionmode2 Values (N'DS Wise Beat Wise Collection', 1)  
Insert Into #TmpCollectionmode2 Values (N'HandHeld Collection', 2)  
Insert Into #TmpCollectionmode2 Values (N'Cash Invoice Collection', 3)  

if  @CollectionMode = '%'              
     Insert into #TmpCollectionmode select Cid from #TmpCollectionmode2
else              
	 Insert into #TmpCollectionmode Select Cid From #TmpCollectionmode2 
		Where collmode in (select * from dbo.sp_SplitIn2Rows( @CollectionMode, @Delimeter))	


--Parameter Temp table

Create Table #TmpParameter (CollID int ,CollType  int)

 if @SalesmanID=N'%'
    Insert into #TmpParameter     
    select documentid,0 from collections  where DocumentDate between @FromDate and @ToDate  and isnull(Status,0) & 192=0
	
 else 
   Insert into #TmpParameter 
   select distinct documentid,0 from collections  where DocumentDate between @FromDate and @ToDate  and isnull(Status,0) & 192=0 and Documentid in (select collectionid from collectiondetail ,invoiceabstract ,#tmpSalesMan where  collectiondetail.DocumentID = Invoiceabstract.Invoiceid and Invoiceabstract.SalesmanID=#tmpSalesMan.SalesmanID)
   union 
   select distinct documentid,0 from collections  where DocumentDate between @FromDate and @ToDate  and isnull(Status,0) & 192=0 and Documentid in (select Documentid from Collections ,#tmpSalesMan where  Collections.SalesmanID=#tmpSalesMan.SalesmanID)

 
 ---Cash Invoice Collection
 Update   #TmpParameter set CollType =  3  where  #TmpParameter.CollID in (select #TmpParameter.CollID from #TmpParameter ,invoiceabstract,CollectionDetail  where #TmpParameter.CollID=CollectionDetail.collectionid and CollectionDetail.documentid=invoiceabstract.invoiceid  and #TmpParameter.CollID=isnull(InvoiceAbstract.Paymentdetails,0) and CollectionDetail.documentType =4 and invoiceabstract.paymentmode = 1)

 --HandHled Collections

 Update   #TmpParameter set CollType =  2  where #TmpParameter.CollID in (select  #TmpParameter.CollID from #TmpParameter,Collection_Details  where #TmpParameter.CollID=Collection_Details.CollectionID)

 -- Dswise BeatWise Collection
 Update   #TmpParameter set CollType =  1  where #TmpParameter.CollID in (select #TmpParameter.CollID from #TmpParameter ,InvoiceWiseCollectiondetail  where #TmpParameter.CollID=InvoiceWiseCollectiondetail.DocumentID)

 insert into #tmpCollectionStatement
	select  C.DocumentID ,  
    "CollectionMode" =case #TmpParameter.CollType 
		when 0 then 'Normal Collection'
		When 1 then 'DS Wise Beat Wise Collection'
		When 2 then  'HandHeld Collection'
		When 3 then  'Cash Invoice Collection'
		End,     
	"PaymentMode" = case IsNull(C.PaymentMode,0)              
		When 0 Then 'Cash'
		When 1 Then 'Cheque'              
		When 2 Then 'DD'              
		When 3 Then 'Credit Card'   
		When 4 Then 'Bank Transfer'
		When 5 Then  'Coupon'             
		End,  
	"Collection Date"		= C.DocumentDate,         
	"Collection ID"			= C.FullDocID,       
	"Collection Reference"   =C.DocumentReference,        
	"Collection Salesman Name" = (select salesman.salesman_name from Salesman,Collections where Collections.SalesmanID = Salesman.SalesmanID and Collections.DocumentID =C.DocumentID),        
    "Document Type" = case CD.DocumentType 
		when 1 then 'Sales Return'
		when 2 then 'Credit Note'
		when 3 then 'Advance Collection'
		when 4 then 'Invoice'
		when 5 then (case when (select flag from debitnote where DebitID = CD.DocumentID) = 2 then 'RepDebitNote' else 'Debit Note' end)
		end,        
	"DocNumber"=case CD.DocumentType  
		when 1 then (select  case ISNULL(GSTFlag,0) when 0 then  VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(GSTFullDocID,'') end from invoiceabstract ,VoucherPrefix  where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid and VoucherPrefix.TranID ='SALES RETURN')
		when 2 then (select VoucherPrefix.Prefix + cast(CreditNote.CreditID as nvarchar) from CreditNote, VoucherPrefix  where CD.DocumentType = 2 and CD.DocumentID = CreditNote.CreditID and VoucherPrefix.TranID ='CREDIT NOTE')
		when 3 then ''
		when 4 then (select case isnull (GSTFlag,0) When 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else Isnull(GSTFullDocID,'') end from invoiceabstract ,VoucherPrefix  where CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid and VoucherPrefix.TranID ='INVOICE')
		when 5 then (select VoucherPrefix.Prefix + cast(DebitNote.DebitID as nvarchar) from DebitNote,VoucherPrefix  where CD.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID and VoucherPrefix.TranID ='DEBIT NOTE')
		end,
	"DocReference"=case CD.DocumentType 
		when 1 then (select isnull(InvoiceAbstract.docserialtype,'') + InvoiceAbstract.Docreference from invoiceabstract   where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid)
		when 2 then (select isnull(CreditNote.docserialtype,'') + CreditNote.DocumentReference from CreditNote   where CD.DocumentType = 2 and CD.DocumentID = CreditNote.CreditID)
		when 3 then ''
		when 4 then (select isnull(InvoiceAbstract.docserialtype,'') + InvoiceAbstract.Docreference from invoiceabstract   where CD.DocumentType = 4  and CD.DocumentID = Invoiceabstract.invoiceid)
		when 5 then (select isnull(DebitNote.docserialtype,'') + DebitNote.DocumentReference from DebitNote   where CD.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID)
		end,
	"DocDate"= case CD.DocumentType 
		when 1 then dbo.mERP_fn_getDateString ((select InvoiceAbstract.InvoiceDate  from invoiceabstract  where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid))
		when 2 then dbo.mERP_fn_getDateString ((select CreditNote.DocumentDate from CreditNote   where CD.DocumentType = 2 and CD.DocumentID = CreditNote.CreditID))
		when 3 then ''
		when 4 then dbo.mERP_fn_getDateString ((select InvoiceAbstract.InvoiceDate  from invoiceabstract   where  CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid))
		when 5 then dbo.mERP_fn_getDateString ((select DebitNote.DocumentDate from DebitNote  where CD.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID))
		end,    
	"CustomerID"=Customer.CustomerID,           
	"CustomerName"=Customer.Company_Name,         
	"Beat"=case CD.DocumentType 
		when 1 then (select Beat.Description  from invoiceabstract,Beat where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid and Invoiceabstract.BeatID = Beat.BeatID)
		when 4 then (select Beat.Description from invoiceabstract,Beat where  CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid and Invoiceabstract.BeatID = Beat.BeatID)
		else ''
		end,    
  	"SalesManID"= case CD.DocumentType 
		when 1 then (select Invoiceabstract.SalesmanID  from invoiceabstract   where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid)			
		when 4 then (select Invoiceabstract.SalesmanID from invoiceabstract  where  CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid)
		else ''
		end,  
	"SalesmanName"=case CD.DocumentType 
		when 1 then (select Salesman.Salesman_Name  from invoiceabstract, Salesman  where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid and Invoiceabstract.SalesmanID =Salesman.SalesmanID ) 			
		when 4 then (select Salesman.Salesman_Name from invoiceabstract,Salesman where  CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid  and Invoiceabstract.SalesmanID =Salesman.SalesmanID )
		else ''
		end,    
	"DSType"=case CD.DocumentType 		 			
		when 4 then (select DSType_Master.DSTypeValue  from DSType_Master ,DSType_Details ,invoiceabstract   where CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid and Invoiceabstract.SalesmanID =DSType_Details.SalesmanID and DSType_Details.DsTypeID = DSType_Master.DsTypeID and DSType_Master.DSTypeName='DSType' )
        	else ''		
		end,    	
	"HandHeldDS"=case isnull(C.SalesmanID,'') 
		when '' then ''
		else
		(select DSType_Master.DSTypeValue  from DSType_Master ,DSType_Details  where  C.SalesmanID =DSType_Details.SalesmanID and DSType_Details.DsTypeID = DSType_Master.DsTypeID and DSType_Master.DSTypeName='Handheld DS' )        
		end,  
			
	"InvoiceAmount" =case CD.DocumentType 
		when 1 then (select InvoiceAbstract.Netvalue  from invoiceabstract where CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid )
		when 2 then (select CreditNote.Notevalue  from CreditNote where CD.DocumentType = 2 and CD.DocumentID = CreditNote.CreditID )
		when 3 then CD.DocumentValue 
		when 4 then (select InvoiceAbstract.Netvalue  from invoiceabstract where CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid)
 		when 5 then (select DebitNote.Notevalue  from DebitNote where CD.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID)
		end,
	"AmountReceived" = 
    -- CD.AdjustedAmount,
	-- Changes done for the CR 10939707. We changed the procedure to show Negative sign for Credit documents.
    -- Changes confirmed by Adhil
        case CD.DocumentType 
		when 1 then 0 - CD.AdjustedAmount--'Sales Return'
		when 2 then 0 - CD.AdjustedAmount -- 'Credit Note'
		when 3 then 0 - CD.AdjustedAmount --'Advance Collection'
		when 4 then CD.AdjustedAmount --'Invoice'
		when 5 then CD.AdjustedAmount -- Debit Note
		end, 
	"AddlAdjustment"=CD.ExtraCollection,
	"ExtraCollection"=C.Balance,
    "TotalCollection"=dbo.mERP_fn_getTotalCollection_rpt(CD.DocumentID, CD.DocumentType, C.documentid),
    "Balance"=case CD.DocumentType 
		when 1 then (select InvoiceAbstract.Balance from invoiceabstract where  CD.DocumentType = 1 and CD.DocumentID = Invoiceabstract.invoiceid)
		when 2 then (select CreditNote.Balance from CreditNote where  CD.DocumentType = 2 and CD.DocumentID = CreditNote.CreditID)
		when 3 then (select Collections.Balance from Collections where Collections.DocumentID = CD.DocumentID and CD.DocumentType = 3) 
		when 4 then (select InvoiceAbstract.Balance from invoiceabstract where  CD.DocumentType = 4 and CD.DocumentID = Invoiceabstract.invoiceid)
		when 5 then (select DebitNote.Balance from DebitNote where  CD.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID)
		end,  
	"Cheque/DDNumber"  = case IsNull(C.PaymentMode,1)
		when  1 then C.ChequeNumber
		when  2 then C.ChequeNumber
		when  4 then C.ChequeNumber
		else ''
		end,       
	"Cheque/DDDate"  = case IsNull(C.PaymentMode,1)
		when  1 then dbo.mERP_fn_getDateString(C.ChequeDate)
		when  2 then dbo.mERP_fn_getDateString(C.ChequeDate)
		when  4 then dbo.mERP_fn_getDateString(C.ChequeDate)
		else ''
		end,         
     "Bank"=case IsNull(C.PaymentMode,1)
		when  1 then (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode)   
		when  2 then  (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode )   
		when  4 then (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode)   
		else ''
		end, 
     "Branch"=case IsNull(C.PaymentMode,1)
		when  1 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		when  2 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		when  4 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		else ''
		end  

	 From Collections C,CollectionDetail CD,Customer,#TmpParameter  where      
		C.DocumentID = CD.CollectionID and	 
		C.DocumentID = #TmpParameter.CollID and
		C.CustomerID =Customer.CustomerID and     
		isnull(C.Status,0) & 192 =0 and
		C.DocumentDate between @FromDate and @ToDate and    
		#TmpParameter.CollType in (select collmode from #TmpCollectionmode) and
        C.Paymentmode in (select paymode from #TmpPaymode)    
        
	union

	select  C.DocumentID ,  
	"CollectionMode" =case #TmpParameter.CollType 
		when 0 then 'Normal Collection'
		When 1 then 'DS Wise Beat Wise Collection'
		When 2 then  'HandHeld Collection'
		When 3 then  'Cash Invoice Collection'
		End,     
	"PaymentMode" = case IsNull(C.PaymentMode,0)              
		When 0 Then 'Cash'
		When 1 Then 'Cheque'              
		When 2 Then 'DD'              
		When 3 Then 'Credit Card'  
		When 4 Then 'Bank Transfer'
		When 5 Then 'Coupon'             
		End,  
	"Collection Date"		   = C.DocumentDate,         
	"Collection ID"			   = C.FullDocID,       
	"Collection Reference"     = C.DocumentReference,        
	"Collection Salesman Name" = (select salesman.salesman_name from Salesman,Collections where Collections.SalesmanID = Salesman.SalesmanID and Collections.DocumentID =C.DocumentID),        
    "Document Type" = 'Advance Collection',		
	"DocNumber"= '',
	"DocReference"='',         
	"DocDate"= '', 
	"CustomerID"=Customer.CustomerID,           
	"CustomerName"=Customer.Company_Name,         
	"Beat" = bt.Description,    
  	"SalesManID"= isnull(C.SalesmanID,''),
	"SalesmanName"= sm.Salesman_Name,    
	"DSType"=case isnull(C.SalesmanID,'') 
		when '' then ''
        else
		(select DSType_Master.DSTypeValue  from DSType_Master ,DSType_Details  where  C.SalesmanID =DSType_Details.SalesmanID and DSType_Details.DsTypeID = DSType_Master.DsTypeID and DSType_Master.DSTypeName='DSType' )        
		end,    
	"HandHeldDS"=case isnull(C.SalesmanID,'') 
		when '' then ''
		else
		(select DSType_Master.DSTypeValue  from DSType_Master ,DSType_Details  where  C.SalesmanID =DSType_Details.SalesmanID and DSType_Details.DsTypeID = DSType_Master.DsTypeID and DSType_Master.DSTypeName='Handheld DS' )        
		end,  
	"InvoiceAmount" =0,
	-- Changes done for the CR 10939707. We changed the procedure to show Negative sign for Credit documents.
    -- Changes confirmed by Adhil
	"AmountReceived" = 0 - C.value,
	"AddlAdjustment"=0,
	"ExtraCollection"=0,
    "TotalCollection"=(C.value -  C.Balance),
    "Balance"=0 - C.Balance,  
	"Cheque/DDNumber"  = case IsNull(C.PaymentMode,1)
		when  1 then C.ChequeNumber
		when  2 then C.ChequeNumber		
		when  4 then C.ChequeNumber		
		else ''
		end,       
	"Cheque/DDDate"  = case IsNull(C.PaymentMode,1)
		when  1 then dbo.mERP_fn_getDateString(C.ChequeDate)
		when  2 then dbo.mERP_fn_getDateString(C.ChequeDate)		
		when  4 then dbo.mERP_fn_getDateString(C.ChequeDate)		
		else ''
		end,         
     "Bank"=case IsNull(C.PaymentMode,1)
		when  1 then (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode)   
		when  2 then  (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode )   
		when  4 then (select Bankmaster.BankName from Bankmaster where C.Bankcode=Bankmaster.bankcode)   
		else ''
		end, 
     "Branch"=case IsNull(C.PaymentMode,1)
		when  1 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		when  2 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		when  4 then (select Branchmaster.BranchName from Branchmaster where C.BranchCode=Branchmaster.Branchcode And C.BankCode=Branchmaster.BankCode)   
		else ''
		end  
	   
      from collections C
	  Inner Join  Customer On C.CustomerID =Customer.CustomerID
	  Inner Join Salesman sm On IsNull(C.SalesmanID, 0) = sm.SalesmanID 
	  Left Outer Join  Beat bt On IsNull(C.BeatID, 0) = bt.BeatID
	  Inner Join #TmpParameter On C.DocumentID = #TmpParameter.CollID 
	  where		isnull(C.Status,0) & 192 =0 and
		C.DocumentDate between @FromDate and @ToDate and    
		#TmpParameter.CollType in (select collmode from #TmpCollectionmode) and
        C.Paymentmode in (select paymode from #TmpPaymode) 
		and C.DocumentID Not In (Select Distinct CollectionID From CollectionDetail) And C.Balance > 0
   
select  
#tmpCollectionStatement.DocumentID ,
"Collection Mode" = #tmpCollectionStatement.CollectionMode,  
"Payment Mode" = #tmpCollectionStatement.Paymode,  
"Collection Date" = #tmpCollectionStatement.CollectionDate, 
"Collection ID" = #tmpCollectionStatement.CollectionID,   
"Collection Reference" = #tmpCollectionStatement.CollectionReference, 
"Collection Salesman Name"  = #tmpCollectionStatement.CollectionSalesmanName,  
"Document Type"= #tmpCollectionStatement.DocumentType, 
"DocNumber" = #tmpCollectionStatement.DocNumber, 
"DocReference" = #tmpCollectionStatement.DocReference,  
"DocDate"= #tmpCollectionStatement.DocDate, 
"CustomerID"=#tmpCollectionStatement.CustomerID,
"CustomerName" =#tmpCollectionStatement.CustomerName,
"Beat"=#tmpCollectionStatement.Beat,
"SalesManID"=#tmpCollectionStatement.SalesmanID,
"SalesmanName"=#tmpCollectionStatement.SalesmanName,
"DS Type"= #tmpCollectionStatement.DSType,
"HandHeld DS"=#tmpCollectionStatement.HandHeldDS,
"Invoice Amount"=#tmpCollectionStatement.InvoiceAmount,
"Amount Received"=#tmpCollectionStatement.AmountReceived,
"Addl Adjustment" =#tmpCollectionStatement.AddlAdjustment,
"ExtraCollection"=#tmpCollectionStatement.ExtraCollection,
"Total Collection"=#tmpCollectionStatement.TotalCollection,
"Balance"=#tmpCollectionStatement.Balance,
"Cheque/DDNumber" =#tmpCollectionStatement.Cheque_DDNumber,
"Cheque/DDDate" = #tmpCollectionStatement.Cheque_DDDate,
"Bank" =#tmpCollectionStatement.Bank,
"Branch" =#tmpCollectionStatement.Branch
from #tmpCollectionStatement where DocumentType not in ('RepDebitNote')



drop table #tmpSalesMan
drop table #TmpPaymode
drop table #TmpPaymode2
drop table #TmpCollectionmode
drop table #TmpCollectionmode2
drop table #TmpParameter
drop table #tmpCollectionStatement   

