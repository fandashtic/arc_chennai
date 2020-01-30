CREATE procedure [dbo].[spr_ser_Salesman_Wise_Sales_MUOM](@Salesman VARCHAR(2550),                 
@FromDATE DATETIME ,
@TODATE DATETIME,
@UOMDesc Varchar(30) )                 
AS                 
Begin -- Procedure Begin
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
      
Create table #tmpSale(Salesman_Name varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      

If @Salesman='%'      
	Insert into #tmpSale select Salesman_Name From Salesman      
Else      
	Insert into #tmpSale select * From dbo.sp_SplitIn2Rows(@Salesman ,@Delimeter)      

Create Table #Temp_Salesman(SaleId Varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Salesman Varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustId Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustName varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
NetVal Decimal(18,6),TotQty Decimal(18,6))
      
If @Salesman = '%'      
Begin      
	-- Trade Invoice For All Salesman
	Insert into #Temp_Salesman
	Select  Cast (IsNull(Salesman.Salesmanid, 0 ) as varchar) +  ',' + (IsNull(InvoiceAbstract.CustomerID,0 )) ,             
	"Salesman" = Case IsNull(Salesman.Salesman_Name, '' ) when '' then 'Others' else Salesman.Salesman_Name end ,                 
	"Customer ID" = IsNull(InvoiceAbstract.CustomerID, ''),           
	"Company Name" = IsNull(Customer.Company_Name, '') ,                 
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0)ELSE IsNull(InvoiceDetail.Amount,0) END),                 
	"Total Quantity" = 
		(Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum(
					Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1.000000 
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum(
					Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1.000000 
					Else 
					Items.UOM2_Conversion End)
				Else 
				 	Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 	
					Else 
					IsNull(InvoiceDetail.Quantity,0) END)End)
	From InvoiceAbstract, InvoiceDetail, Customer, Salesman, Items                 
	Where InvoiceAbstract.Customerid *= Customer.Customerid                 
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid                 
	And InvoiceAbstract.InvoiceDate between @FromDATE And @TODATE                 
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID                 
	And Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSale)           
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0                 
	And InvoiceAbstract.InvoiceType in (1,3,4)                 
	And InvoiceDetail.Product_Code = Items.Product_Code
	Group By  Salesman.Salesmanid , Salesman.Salesman_name,                 
	InvoiceAbstract.CustomerID, Customer.Company_Name,                 
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM    
	Order By Salesman.Salesman_name              

	--Service Invoice For all Salesman          	
	Insert into #Temp_Salesman
	Select  '0' +  ',' + (IsNull(SerAbs.CustomerID,0 )),
	"Salesman" = 'Others',
	"Customer ID" = IsNull(SerAbs.CustomerID, ''),           
	"Company Name" = IsNull(Customer.Company_Name, '') ,                 
	"Net Value (%c)" = Sum(IsNull(SerDet.NetValue,0)),                 
	"Total Quantity" =  
		(Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum(IsNull(SerDet.Quantity,0)), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1.000000 
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum(IsNull(SerDet.Quantity,0)), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1.000000 
					Else 
					Items.UOM2_Conversion End)      
				Else 
					Sum(IsNull(SerDet.Quantity,0))End)
	From ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet, Customer, Items                 
	Where SerAbs.Customerid = Customer.Customerid                 
	And SerAbs.ServiceInvoiceid = SerDet.ServiceInvoiceid                 
	And SerAbs.ServiceInvoiceDate between @FromDATE And @TODATE
	And SerDet.SpareCode = Items.Product_Code
	And IsNull(SerAbs.Status,0) & 192  = 0                 
	And IsNull(SerAbs.ServiceInvoiceType,0) =1
	And IsNull(SerDet.SpareCode,'') <> ''
	Group By  SerAbs.CustomerID,Customer.Company_Name,            
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM    	
End      
Else      
Begin      
	--Trade Invoice for Particular Salesman
	Insert into #Temp_Salesman
	select  Cast (IsNull(Salesman.Salesmanid, 0 ) as varchar) +  ',' + (IsNull(InvoiceAbstract.CustomerID,0 )) ,             
	"Salesman" = IsNull(Salesman.Salesman_Name, '' ),                 
	"Customer ID" = IsNull(InvoiceAbstract.CustomerID, ''),           
	"Company Name" = IsNull(Customer.Company_Name, '') ,                 
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) ELSE IsNull(InvoiceDetail.Amount,0) END),                 
	"Total Quantity" = 
		(Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum(
					Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1.000000
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum(
					Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1.000000 
					Else 
					Items.UOM2_Conversion End)
				Else 
				 	Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 	
					Else 
					IsNull(InvoiceDetail.Quantity,0) END)End)
	From InvoiceAbstract, InvoiceDetail, Customer, Salesman, Items
	Where InvoiceAbstract.Customerid *= Customer.Customerid                 
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid                 
	And InvoiceAbstract.InvoiceDate between @FromDATE And @TODATE                 
	And InvoiceAbstract.SalesmanID = Salesman.SalesmanID                 
	And Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSale)               
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0                 
	And InvoiceAbstract.InvoiceType in (1,3,4)                 
	And InvoiceDetail.Product_Code = Items.Product_Code
	Group By  Salesman.Salesmanid , Salesman.Salesman_name,                 
	InvoiceAbstract.CustomerID, Customer.Company_Name,                 
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM    
	Order By Salesman.Salesman_name       
End
Begin
	Select SaleId ,Salesman as "Salesman",CustId as "Customer ID",CustName as "Company Name",                
	Sum(NetVal) as "Net Value (%c)",Sum(TotQty)  as "Total Quantity"  
	From #Temp_Salesman 
	Group By SaleId,Salesman,CustId,CustName
	Order By Salesman

	Drop Table #Temp_Salesman
End
End --Procedure End
