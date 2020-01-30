
Create Procedure spr_ser_get_SalesmanSalesSummary_Detail (@SalesmanID varchar(50), 
@FromDate DateTime, @ToDate DateTime)
as
Begin --Procedure Begin
-- If SalesmanId > 0 ,Fields Taken from Invoice
If @SalesmanID > 0 
	Select Distinct dbo.StripDateFromTime(InvAbs.InvoiceDate) , 
	"Invoice Date" = dbo.StripDateFromTime(InvAbs.InvoiceDate), 
	"Quantity" = Sum(IsNull(InvDet.Quantity,0)),
	"Value" = sum(case InvAbs.InvoiceType when 4 then -IsNull(InvDet.Amount,0) else IsNull(InvDet.Amount,0) end)
	From InvoiceAbstract InvAbs, InvoiceDetail InvDet
	Where InvAbs.InvoiceID = InvDet.InvoiceID 
	And InvAbs.InvoiceDate Between @FromDate And @ToDate 
	And IsNull(InvAbs.SalesmanID,0) = @SalesmanID 
	And IsNull(InvAbs.Status,0) & 192 = 0
	And InvAbs.InvoiceType not in (2,5,6)
	Group by dbo.StripDateFromTime(InvAbs.InvoiceDate)
Else
Begin
	-- Fields Taken from Invoice And Service
	Create Table #Temp(InvDate DateTime,InvoiceDate DateTime,Qty Decimal(18,6),Val Decimal(18,6))
	--Invoice
	Insert into #Temp
	Select Distinct dbo.StripDateFromTime(InvAbs.InvoiceDate)	, 
	"Invoice Date" = dbo.StripDateFromTime(InvAbs.InvoiceDate), 
	"Quantity" = Sum(IsNull(InvDet.Quantity,0)),
	"Value" = sum(case InvAbs.InvoiceType when 4 then - IsNull(InvDet.Amount,0) else IsNull(InvDet.Amount,0) end)
	From InvoiceAbstract InvAbs, InvoiceDetail InvDet
	Where InvAbs.InvoiceID = InvDet.InvoiceID 
	And InvAbs.InvoiceDate Between @FromDate And @ToDate 
	And IsNull(InvAbs.SalesmanID,0) = @SalesmanID 
	And IsNull(InvAbs.Status,0) & 192 = 0
	And InvAbs.InvoiceType not in (2,5,6)
	Group by dbo.StripDateFromTime(InvAbs.InvoiceDate)

	--Service
	Insert into #Temp
	Select Distinct dbo.StripDateFromTime(SerAbs.ServiceInvoiceDate) , 
	"Invoice Date" = dbo.StripDateFromTime(SerAbs.ServiceInvoiceDate), 
	"Quantity" = Sum(IsNull(SerDet.Quantity,0)),
	"Value" = Sum(IsNull(SerDet.NetValue,0))
	From ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet
	Where SerAbs.ServiceInvoiceID = SerDet.ServiceInvoiceID
	And SerAbs.ServiceInvoiceDate Between @FromDate And @ToDate
	And IsNull(SerAbs.Status,0) & 192 = 0
	And IsNull(SerAbs.ServiceInvoiceType,0) = 1
	And IsNull(SpareCode,'') <> ''
	Group by dbo.StripDateFromTime(SerAbs.ServiceInvoiceDate)
End
	Select InvDate,InvoiceDate as "Invoice Date",Sum(Qty) as Quantity,Sum(Val) as Value
	From #Temp
	Group By InvDate,InvoiceDate 
	Order By InvoiceDate

	Drop Table #Temp
End -- Procedure End

