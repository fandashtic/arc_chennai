Create Procedure spr_ser_get_SalesmanSalesSummary_Abstract(@SalesMan varchar(2550), 
@FromDate DateTime, @ToDate DateTime)
As

Begin
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpCus(Salesman_Name varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
If @Salesman='%'  
	Insert into #tmpCus select Salesman_Name from Salesman 
Else  
	Insert into #tmpCus select * from dbo.sp_ser_SplitIn2Rows(@Salesman,@Delimeter)  

Create Table #Temp_Sales(SalesmanID  Int,
Salesman varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Value Decimal(18,6)) 

If @Salesman = '%'
Begin
	---Invoice
	Insert into #Temp_Sales
	Select IsNull(InvAbs.SalesManID,0), 
	"Salesman" = IsNull(SM.SalesMan_Name, 'Others'), 
	"Value" = Sum(Case InvAbs.InvoiceType when 4 then - IsNull(InvDet.Amount,0) else  IsNull(InvDet.Amount,0) end)
	From InvoiceAbstract InvAbs
	Inner Join InvoiceDetail InvDet On
	InvAbs.InvoiceID = InvDet.InvoiceID 
	Left Outer Join SalesMan SM On 
	InvAbs.SalesmanID = SM.SalesmanID
	Where (@Salesman = '%' or SM.Salesman_Name in (Select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus))
	And InvAbs.InvoiceDate Between @FromDate And @ToDate 
	And IsNull(InvAbs.Status,0) & 192 = 0
	And InvAbs.InvoiceType not in (2,5,6)
	Group by InvAbs.SalesManID, SM.SalesMan_Name
	---Service Invoice
	Insert into #Temp_Sales
	Select 0,
	"Salesman" =  'Others', 
	"Value" = Sum(IsNull(SerDet.NetValue,0))
	From ServiceInvoiceAbstract SerAbs,ServiceInvoiceDetail SerDet 
	Where SerAbs.ServiceInvoiceID = SerDet.ServiceInvoiceID 
	And SerAbs.ServiceInvoiceDate Between @FromDate And @ToDate 
	And IsNull(SerAbs.Status,0) & 192 = 0
	And IsNull(SerAbs.ServiceInvoiceType,0) = 1
	And IsNull(SpareCode,'') <> ''
	Group by SerAbs.ServiceInvoiceId
End
Else
Begin
	Insert into #Temp_Sales
	Select IsNull(InvAbs.SalesManID,0), 
	"Salesman" = IsNull(SM.SalesMan_Name, 'Others'), 
	"Value" = Sum(Case InvAbs.InvoiceType when 4 then - IsNull(InvDet.Amount,0) else  IsNull(InvDet.Amount,0) end)
	From InvoiceAbstract InvAbs
	Inner Join InvoiceDetail InvDet On
	InvAbs.InvoiceID = InvDet.InvoiceID 
	Left Outer Join SalesMan SM On 
	InvAbs.SalesmanID = SM.SalesmanID
	Where SM.Salesman_Name in (Select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCus)
	And InvAbs.InvoiceDate Between @FromDate And @ToDate 
	And IsNull(InvAbs.Status,0) & 192 = 0
	And InvAbs.InvoiceType not in (2,5,6)
	Group by InvAbs.SalesManID, SM.SalesMan_Name
End
Begin
	Select SalesmanId,Salesman,Sum(Value) as Value 
	From #Temp_Sales 
	Group by SalesmanId,Salesman
	Order by Salesman

	Drop Table #Temp_Sales
End
End --Procedcure End
