CREATE procedure [dbo].[spr_ser_customerwise_sales](@FROMDATE datetime,  
     @TODATE datetime,  
     @CusType nVarchar(50))  
AS  
Declare @CurFromDate As Datetime  
Declare @CurToDate As Datetime  
Declare @YearFromDate As Datetime  
Declare @YearToDate As Datetime  
Declare @FiscalYear Int  
Declare @TransDate  as Datetime

Set @CurFromDate =  '01/' +   
Cast(DatePart(mm, GetDate()) As Varchar) + '/' +  
Cast(DatePart(yyyy, GetDate()) As Varchar)  
  
Set @CurToDate = Cast(DatePart(dd, GetDate()) As Varchar) + '/' +  
Cast(DatePart(mm, GetDate()) As Varchar) + '/' +  
Cast(DatePart(yyyy, GetDate()) As Varchar)  
Set @CurToDate = DateAdd(d, 1, @CurToDate)  

Select @FiscalYear = FiscalYear,@TransDate = OpeningDate From Setup  

Set @YearFromDate = '01/0' + Cast(@FiscalYear As Varchar) + '/' +   
Cast(DatePart(yyyy, @TransDate) As Varchar)  

Set @YearToDate = @CurToDate  



Create Table #CustomerTotal(CustID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
Customer varchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Goods Value - Sales] decimal(18,6),[Goods Value - Sales Return Saleable] decimal(18,6),
[Goods Value - Sales Return Damages]  decimal(18,6),
[Total Tax Suffered] decimal(18,6),[Total Discount] decimal(18,6),
[Total Tax Applicable] decimal(18,6),
[NetSales] decimal(18,6),
[Current Month No. Of Sales] decimal(18,6),
[Current Month Sales] decimal(18,6),
[Current Month No.Of Sales Return]  decimal(18,6),  
[Current Month Sales Return]  decimal(18,6),    
[Year to Date No.Of Sales] decimal(18,6),  
[Year to Date Sales] decimal(18,6),
[Year to Date No.Of Sales Return] decimal(18,6),
[Year to date Sales Return] decimal(18,6))
  
If @CusType = 'Trade'  
Begin  
Select InvoiceAbstract.CustomerID,  
"CustomerID" = InvoiceAbstract.CustomerID,  
"Customer" = Customer.Company_Name,  
"Goods Value - Sales (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceAbstract.GoodsValue End)  
When 0 Then  
''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceAbstract.GoodsValue End) As Varchar)  
End,  
"Goods Value - Sales Return Saleable (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
Case InvoiceAbstract.Status & 32 When 0 then InvoiceAbstract.GoodsValue Else 0 End  
Else  
0  
End)  
When 0 Then  
''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
Case InvoiceAbstract.Status & 32 When 0 then InvoiceAbstract.GoodsValue Else 0 End  
Else  
0  
End) As Varchar)  
End,  
"Goods Value - Sales Return Damages (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
Case InvoiceAbstract.Status & 32 When 0 Then 0 Else InvoiceAbstract.GoodsValue End  
Else  
0  
End)  
When 0 Then  
''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
Case InvoiceAbstract.Status & 32 When 0 Then 0 Else InvoiceAbstract.GoodsValue End  
Else  
0  
End) As Varchar)  
End,  
"Total Tax Suffered (%c)" = Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
0 - TotalTaxSuffered  
Else  
TotalTaxSuffered  
End),  
"Total Discount (%c)" = Sum(Case InvoiceType  
When 4 Then  
0 - (DiscountValue + AddlDiscountValue + ProductDiscount)  
Else  
(DiscountValue + AddlDiscountValue + ProductDiscount)  
End),  
"Total Tax Applicable (%c)" = Sum(Case InvoiceType  
When 4 Then  
0 - TotalTaxApplicable  
Else  
TotalTaxApplicable  
End),  
"NetSales" = Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
0 - InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)  
Else  
InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)  
End),  
"Current Month No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Current Month Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Current Month No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4),  
  
"Current Month Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4),  
  
"Year to Date No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Year to Date Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Year to Date No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4),  
  
"Year to date Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4)  
  
From InvoiceAbstract, Customer  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.CustomerID = Customer.CustomerID And  
InvoiceAbstract.InvoiceType in (1, 3, 4)  
Group By InvoiceAbstract.CustomerID, Customer.Company_Name  
Order By InvoiceAbstract.CustomerID, "NetSales" Desc  
End  
Else  
Begin  

Insert into #CustomerTotal
  
Select Case Isnull(InvoiceAbstract.CustomerID, '') When '' Then 'Others' Else InvoiceAbstract.CustomerID End,  
"CustomerID" = Case Isnull(InvoiceAbstract.CustomerID, '') When '' Then 'Others' Else InvoiceAbstract.CustomerID End,  
"Customer" = Case isnull(Customer.Company_Name, '') When '' Then 'Others' Else Customer.Company_Name End,  
"Goods Value - Sales (%c)" = Cast(Sum(InvoiceAbstract.GoodsValue) As Varchar),  
"Goods Value - Sales Return Saleable (%c)" = Sum(Case InvoiceAbstract.InvoiceType When 5 Then
InvoiceAbstract.GoodsValue Else 0 end),
"Goods Value - Sales Return Damages (%c)" = Sum(Case InvoiceAbstract.InvoiceType When 6 Then
InvoiceAbstract.GoodsValue Else 0 end),  
"Total Tax Suffered (%c)" = Sum(TotalTaxSuffered),  
"Total Discount (%c)" = Sum((DiscountValue + AddlDiscountValue + ProductDiscount)),  
"Total Tax Applicable (%c)" = Sum(TotalTaxApplicable),  
"NetSales" = Sum(InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)),  
  
"Current Month No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2,5,6)),
  
"Current Month Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Current Month No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Current Month Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Year to Date No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Year to Date Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Year to Date No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Year to date Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6))    

From InvoiceAbstract, Customer  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.CustomerID *= Customer.CustomerID And  
InvoiceAbstract.InvoiceType in (2,5,6)  
Group By InvoiceAbstract.CustomerID, Customer.Company_Name
Order By InvoiceAbstract.CustomerID, "NetSales" Desc  


Insert into #CustomerTotal

Select Case Isnull(ServiceInvoiceAbstract.CustomerID, '') When '' Then 'Others' Else ServiceInvoiceAbstract.CustomerID End,  
"CustomerID" = Case Isnull(ServiceInvoiceAbstract.CustomerID, '') When '' Then 'Others' Else ServiceInvoiceAbstract.CustomerID End,  
"Customer" = Case isnull(Customer.Company_Name, '') When '' Then 'Others' Else Customer.Company_Name End,  

"Goods Value - Sales (%c)" = 	isnull((select sum(isnull(serviceinvoicedetail.netvalue,0)) 
				from serviceInvoiceAbstract as Inv,serviceinvoicedetail
		     		where Inv.serviceInvoiceID=serviceInvoicedetail.serviceInvoiceID       
				And inv.serviceinvoicedate between @FromDate and @Todate
				And isnull(Inv.Status,0)& 192 =0 
				And Inv.serviceInvoiceType in (1)      
				And isnull(serviceinvoicedetail.sparecode,'') <> ''
	                       And Inv.CustomerID = ServiceInvoiceAbstract.CustomerID),0),

"Goods Value - Sales Return Saleable (%c)" = 0,
"Goods Value - Sales Return Damages (%c)" = 0,  
"Total Tax Suffered (%c)" = Sum(Isnull(TotalTaxSuffered,0)), 
  
"Total Discount (%c)" = Sum(Isnull(ItemDiscount,0) + isnull(AdditionalDiscountValue_spare,0) + Isnull(TradeDiscountvalue_spare,0)),  

"Total Tax Applicable (%c)" = Sum(Isnull(TotalTaxApplicable,0)),  

"NetSales" = isnull((select sum(isnull(serviceinvoicedetail.netvalue,0))       
				from serviceInvoiceAbstract as Inv,serviceinvoicedetail
		     		where Inv.serviceInvoiceID=serviceInvoicedetail.serviceInvoiceID       
				And inv.serviceinvoicedate between @FromDate and @Todate
				And isnull(Inv.Status,0)& 192 =0 
				And Inv.serviceInvoiceType in (1)      
				And isnull(serviceinvoicedetail.sparecode,'') <> ''
                                And Inv.CustomerID = ServiceInvoiceAbstract.CustomerID),0),  
  

"Current Month No. Of Sales" = (Select Count(*)   
				From ServiceInvoiceAbstract As Inv,Serviceinvoicedetail
				Where Inv.serviceInvoiceDate Between @CurFromDate And @CurToDate And  
				Inv.serviceInvoiceID=serviceInvoicedetail.serviceInvoiceID       
				And isnull(serviceinvoicedetail.sparecode,'') <> ''
				And Isnull(Inv.Status,0) & 192 = 0 And  
				Inv.CustomerID = ServiceInvoiceAbstract.CustomerID), 

  
"Current Month Sales (%c)" = isnull((Select Sum(serviceinvoicedetail.NetValue) 
				From ServiceInvoiceAbstract As Inv,Serviceinvoicedetail
				Where Inv.serviceInvoiceDate Between @CurFromDate And @CurToDate And  
				Isnull(Inv.Status,0) & 192 = 0  
				And Inv.ServiceInvoiceType in (1)
				And Inv.Serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid
				And isnull(serviceinvoicedetail.sparecode,'') <> ''  
				And Inv.CustomerID = ServiceInvoiceAbstract.CustomerID),0),  
  
"Current Month No. Of Sales Return" = 0,  
  
"Current Month Sales Return (%c)" = 0,  
  
"Year to Date No. Of Sales" = (Select Count(*)   
				From ServiceInvoiceAbstract As Inv,ServiceInvoicedetail
				Where Inv.serviceInvoiceDate Between @YearFromDate And @YearToDate 
				And Inv.serviceInvoiceID=serviceInvoicedetail.serviceInvoiceID       
				And isnull(serviceinvoicedetail.sparecode,'') <> ''
				And Isnull(Inv.Status,0) & 192 = 0 And  
				Inv.CustomerID = ServiceInvoiceAbstract.CustomerID),
				  
"Year to Date Sales (%c)" = isnull((select Sum(ServiceInvoiceDetail.NetValue) 
				From ServiceInvoiceAbstract As Inv,Serviceinvoicedetail
				Where Inv.serviceInvoiceDate Between @YearFromDate And @YearToDate And  
				Isnull(Inv.Status,0) & 192 = 0  
				And Inv.serviceInvoiceID=serviceInvoicedetail.serviceInvoiceID       
				And Inv.ServiceInvoiceType in (1)
				And isnull(serviceinvoicedetail.sparecode,'') <> ''  
				And Inv.CustomerID = ServiceInvoiceAbstract.CustomerID),0),
				 
"Year to Date No. Of Sales Return" = 0,  
  
"Year to date Sales Return (%c)" = 0    

From ServiceInvoiceAbstract,Customer  
Where ServiceInvoiceAbstract.ServiceInvoiceDate Between @FromDate And @Todate 
And  isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 And  
ServiceInvoiceAbstract.CustomerID *= Customer.CustomerID 
Group By ServiceInvoiceAbstract.CustomerID, Customer.Company_Name
Order By ServiceInvoiceAbstract.CustomerID,"NetSales" Desc  


select"Customer ID" = customerid,
"Customer" = customer,
"Goods Value -Sales" = sum([Goods Value - Sales]),
"Goods Value - Sales Return Saleable" = sum([Goods Value - Sales Return Saleable]),
"Total Tax Suffered" =sum([Total Tax Suffered]),
"Total Discount" = sum([Total Discount]),
"Total Tax Applicable" = sum([Total Tax Applicable]),
"NetSales" =sum([NetSales]),
"Current Month No. Of Sales" = sum([Current Month No. Of Sales]),
"Current Month Sales" = sum([Current Month Sales]),
"Current Month No.Of Sales Return" = sum([Current Month No.Of Sales Return]),
"Current Month Sales Return" = sum([Current Month Sales Return]),
"Year To Date No.Of Sales" = sum([Year To Date No.Of Sales]),
"Year To Date Sales" = sum([Year To Date Sales]),
"Year To Date No.Of Sales Return" = sum([Year To Date No.Of Sales Return]),
"Year To Date Sales Return" = sum([Year To Date Sales Return]) from #CustomerTotal

Group By #customerTotal.CustomerID, #customerTotal.Customer
Order By #customerTotal.CustomerID,[NetSales] Desc 
drop table #CustomerTotal
End
