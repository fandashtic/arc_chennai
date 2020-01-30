CREATE procedure spr_Weeklycoverageplan_abstract     
(@fromdate datetime,@salesmancode nvarchar(255))          
as   
Declare @salesname nvarchar(255)     
Declare @volumetilldate nvarchar(11)         
declare @salescode nvarchar(255)    
declare @Assigndate nvarchar(25)    
declare @Assigntempdate nvarchar(5)    
declare @insertcolumn nvarchar(25)
declare @insertfromdate nvarchar(25)      

set @insertfromdate = '01' + '/' +  Cast(DatePart(mm, @fromdate) as NVarchar(2)) + '/' + Cast(DatePart(yyyy, @fromdate) as nvarchar(4))    

Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpSalesMan(SalesmanCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @Salesmancode = N'%'       
   Insert into #tmpSalesMan select SalesmanCode from Salesman Where Active = 1     
Else      
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@salesmancode,@Delimeter)      

Select Distinct salesmancode
,"Salesman Name" = salesman_name  
,"Monthly Volume Objective" = (Select IsNull(SUM(sp.volume), 0) From SalesmanScopeDetail sp Where salesman.salesmancode = sp.salesmancode And sp.objmonth = Month(@FromDate)  And sp.objyear = Year(@FromDate))
,"Volume TillDate" = IsNull((Select IsNull(SUM(quantity) , 0)
From invoiceabstract as ivt , invoicedetail as idt
Where ivt.invoiceid = idt.invoiceid And 
ivt.salesmanid = salesman.salesmanid And 
IsNull(ivt.InvoiceType,0) in (1,3) And
ivt.invoicedate between CAST(@insertfromdate as datetime) and @fromdate And 
((Ivt.Status & 128) = 0)
Group By ivt.salesmanid  ), 0)
From salesman 
Where 
salesman.salesmancode In (Select SalesmanCode COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSalesMan) 





