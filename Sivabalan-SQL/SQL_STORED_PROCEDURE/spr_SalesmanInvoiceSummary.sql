Create Procedure spr_SalesmanInvoiceSummary
(
--@Salesman nVarchar (2550) ,
--@Beat nVarchar(2550) ,
@FromDate Datetime,
@ToDate Datetime,
@VANumber nVarchar(2000)
)
As
Begin
Set Dateformat DMY

Declare @Delimeter as Char(1)
Set @Delimeter = Char(15)

--Create table #tmpSalesMan(SalesManName nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
--Create table #tmpBeat (BeatName nVarchar(500)COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpAllVANum(AllVAFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpVANumber(ID Int Identity(1,1),VAFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tmpVAInvoices(InvoiceID Int,ShipmentNo Int ,SeqNo Int,GSTFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 

--If @Salesman='%'   
--	Insert into #tmpSalesMan select salesman_name From SalesMan  
--Else  
--	Insert into #tmpSalesMan Select SalesmanID  From Salesman Where salesman_name In (Select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))
		 	 
--If @Beat='%'
--	Insert Into #tmpBeat Select [Description] From Beat
--Else
--	Insert Into #tmpBeat Select BeatID From Beat Where [Description] In (Select * From dbo.sp_SplitIn2Rows(@Beat, @Delimeter))  

If @VANumber = '%' or @VANumber = '' 
	Insert into #tmpAllVANum (AllVAFullDocID) Select FullDocID From VAllocAbstract Where dbo.StripTimeFromDate(AllocDate) Between @FromDate and @ToDate 
Else
	Insert into #tmpAllVANum (AllVAFullDocID) Select ItemValue From dbo.sp_SplitIn2Rows(@VANumber,@Delimeter)
	
	Insert into #tmpVANumber (VAFullDocID) 
	Select "ItemValue" = Case When CHARINDEX('(',AllVAFullDocID,1) > 0 Then SubString(AllVAFullDocID,1,CHARINDEX('(',AllVAFullDocID,1)-1) Else AllVAFullDocID End From #tmpAllVANum
	--Select "ItemValue" = LTrim(RTrim(ItemValue)) From dbo.sp_SplitIn2Rows(@VANumber,'(')

	Insert Into #tmpVAInvoices (InvoiceID, ShipmentNo, SeqNo,GSTFullDocID )
	Select VAD.InvoiceID,VAA.ShipmentNo  ,VAD.SequenceNo ,VAD.GSTFullDocID 
	From VAllocAbstract VAA 
	Inner Join VAllocDetail VAD On VAD.VAllocID = VAA.ID 
	Inner Join #tmpVANumber V On V.VAFullDocID = VAA.FullDocID
	And VAA.Status & 64 = 0

IF (Select SUM(SeqNo) From #tmpVAInvoices) > 0
	Select * From (Select 
	Distinct "SeqNo" = VAI.SeqNo ,
	"InvoiceID" = ISNULL(Invabs.GSTFullDocID,''),
	"DocReference" = ISNULL(Invabs.DocReference,''),
	"Date" = dbo.StripTimeFromDate(Invabs.InvoiceDate),
	"CustomerID" = ISNULL(Invabs.CustomerID,''),
	"Customer" = ISNULL(C.Company_Name,''),
	"Salesman" = Isnull(S.Salesman_Name,''), 
	"Beat" = Isnull(B.Description,''),
	"PaymentMode" = Case when (Invabs.PaymentMode = 0) Then 'Credit' When (Invabs.PaymentMode = 1) Then 'Cash' Else ''  End,	
	--"GoodsValue" = (ISNULL (Invabs.GoodsValue,0)),
	"GoodsValue" = IsNull(Sum(InvDet.UOMQty * InvDet.UOMPrice),0),
	"Discount" = SUM(InvDet.DiscountValue) + Isnull(Invabs.AddlDiscountValue,0),
	"TaxAmount(rs.)" = Sum(Isnull(InvDet.STPayable,0) + Isnull(InvDet.CSTPayable,0)),
	"NetValue" = Isnull(Invabs.NetValue,0)	
	 ,"Shipment No." = VAI.ShipmentNo  
	 ,"Sequence No." =  VAI.SeqNo 
	From Invoiceabstract  Invabs
	Join InvoiceDetail InvDet On Invabs.InvoiceID = InvDet.InvoiceID
	Join Customer C ON Invabs.CustomerID = C.CustomerID 
	Join Salesman S ON Invabs.SalesmanID = S.SalesmanID
	Join Beat B ON Invabs.BeatID = B.BeatID 
	Join #tmpVAInvoices VAI On VAI.GSTFullDocID = Invabs.GSTFullDocID  --VAI.InvoiceID = Invabs.InvoiceID   
	Where ISNULL(Invabs.Status, 0) & 128 = 0
	And Invabs.Invoicetype in (1,3)	
	Group By VAI.ShipmentNo,VAI.SeqNo,Invabs.GSTFullDocID, Invabs.DocReference, dbo.StripTimeFromDate(Invabs.InvoiceDate), Invabs.CustomerID, C.Company_Name, S.Salesman_Name, B.Description,
	Invabs.PaymentMode, Invabs.AddlDiscountValue, Invabs.NetValue) Res
	Order by Res.SeqNo 
Else
	Select * from (Select 
	Distinct "ID" = 0 ,
	"InvoiceID" = ISNULL(Invabs.GSTFullDocID,''),
	"DocReference" = ISNULL(Invabs.DocReference,''),
	"Date" = dbo.StripTimeFromDate(Invabs.InvoiceDate),
	"CustomerID" = ISNULL(Invabs.CustomerID,''),
	"Customer" = ISNULL(C.Company_Name,''),
	"Salesman" = Isnull(S.Salesman_Name,''), 
	"Beat" = Isnull(B.Description,''),
	"PaymentMode" = Case when (Invabs.PaymentMode = 0) Then 'Credit' When (Invabs.PaymentMode = 1) Then 'Cash' Else ''  End,
	--"GoodsValue" = (ISNULL (Invabs.GoodsValue,0)),
	"GoodsValue" = IsNull(Sum(InvDet.UOMQty * InvDet.UOMPrice),0),
	"Discount" = SUM(InvDet.DiscountValue) + Isnull(Invabs.AddlDiscountValue,0),
	"TaxAmount(rs.)" = Sum(Isnull(InvDet.STPayable,0) + Isnull(InvDet.CSTPayable,0)),
	"NetValue" = Isnull(Invabs.NetValue,0)	
	 ,"Shipment No." = VAI.ShipmentNo  
	 ,"Sequence No." =  VAI.SeqNo 
	From Invoiceabstract  Invabs
	Join InvoiceDetail InvDet On Invabs.InvoiceID = InvDet.InvoiceID
	Join Customer C ON Invabs.CustomerID = C.CustomerID 
	Join Salesman S ON Invabs.SalesmanID = S.SalesmanID
	Join Beat B ON Invabs.BeatID = B.BeatID 
	Join #tmpVAInvoices VAI On VAI.GSTFullDocID = Invabs.GSTFullDocID  --VAI.InvoiceID = Invabs.InvoiceID   
	Where ISNULL(Invabs.Status, 0) & 128 = 0
	And Invabs.Invoicetype in (1,3)	
	Group By VAI.ShipmentNo,VAI.SeqNo,Invabs.GSTFullDocID, Invabs.DocReference, dbo.StripTimeFromDate(Invabs.InvoiceDate), Invabs.CustomerID, C.Company_Name, S.Salesman_Name, B.Description,
	Invabs.PaymentMode, Invabs.AddlDiscountValue,  Invabs.NetValue) Res
	Order by dbo.StripTimeFromDate(Res.Date),Res.InvoiceID 

	--Drop Table #tmpSalesMan
	--Drop Table #tmpBeat
	Drop Table #tmpVANumber
	Drop Table #tmpVAInvoices

END
