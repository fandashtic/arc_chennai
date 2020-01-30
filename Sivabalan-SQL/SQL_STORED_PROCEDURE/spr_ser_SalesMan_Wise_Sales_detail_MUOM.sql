CREATE procedure [dbo].[spr_ser_SalesMan_Wise_Sales_detail_MUOM](@SALES_CUST NVARCHAR(100),         
      @FromDATE DATETIME ,         
      @TODATE DATETIME, @UOMDesc Varchar(30) )        
AS        
Begin -- Procedure Begin
Declare @SALE Int  
Declare @CUST NVarchar(50)      
Declare @LENSTR Int      
Set @LENSTR = (CHARINDEX(',', @SALES_CUST) )       
Select @SALE = Cast (SUBSTRING(@SALES_CUST,  1 , (@lENSTR - 1 )) as Int)  
Select @CUST = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )      

--If SaleId > 0 it takes details From Invoice
If @SALE > 0
	Select  InvoiceDetail.Product_Code,   
	"Item Name" = Items.ProductName,         
	"Quantity" = 
	Cast((Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) Else IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) Else IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM2_Conversion End)
				Else 
				 	Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 	
					Else 
					IsNull(InvoiceDetail.Quantity,0) END)End) as Varchar)  
				+ ' ' + 
	Cast((Case 	When @UOMdesc = 'UOM1' then 
					IsNull((Select Description From UOM Where UOM = Items.UOM1),'')      
				When @UOMdesc = 'UOM2' then 
					IsNull((Select Description From UOM Where UOM = Items.UOM2),'')      
				Else
					IsNull((Select Description From UOM Where UOM = Items.UOM), '')
				End) as Varchar),  
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) Else IsNull(InvoiceDetail.Amount,0) END)        
	From InvoiceAbstract, InvoiceDetail, Items, Salesman  , Customer      
	Where InvoiceDetail.Product_Code = Items.Product_Code        
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid        
	And InvoiceAbstract.InvoiceDate between @FromDATE And @TODATE        
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID        
	And IsNull(InvoiceAbstract.Salesmanid, 0)  =  @SALE      
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0        
	And InvoiceAbstract.InvoiceType in (1,3,4)        
	And InvoiceAbstract.Customerid = Customer.Customerid      
	And InvoiceAbstract.Customerid like @CUST      
	Group By InvoiceDetail.Product_Code, Items.ProductName,   
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM    
	Order by Items.ProductName
Else
Begin
	--If SaleId = 0 it takes details From Invoice And Service Invoice
	--Invoice
	Create Table #Temp(ProductCode Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProdName Varchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Qty Decimal(18,6),Net Decimal(18,6))

	Insert into #Temp
	Select  InvoiceDetail.Product_Code,   
	"Item Name" = Items.ProductName,         
	"Quantity" = 
		(Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum
					(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum
					(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM2_Conversion End)      
				Else 
					Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Quantity,0) 
					Else 
					IsNull(InvoiceDetail.Quantity,0) END)End),  
	"Net Value (%c)" = Sum(Case InvoiceAbstract.InvoiceType when 4 then 0 - IsNull(InvoiceDetail.Amount,0) Else IsNull(InvoiceDetail.Amount,0) END)        
	From InvoiceAbstract, InvoiceDetail, Items, Salesman  , Customer      
	Where InvoiceDetail.Product_Code = Items.Product_Code        
	And InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid        
	And InvoiceAbstract.InvoiceDate between @FromDATE And @TODATE        
	And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID        
	And IsNull(InvoiceAbstract.Salesmanid, 0)  =  @SALE      
	And IsNull(InvoiceAbstract.Status,0) & 128  = 0        
	And InvoiceAbstract.InvoiceType in (1,3,4)        
	And InvoiceAbstract.Customerid = Customer.Customerid      
	And InvoiceAbstract.Customerid like @CUST      
	Group By InvoiceDetail.Product_Code, Items.ProductName,   
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM    

	--Service Invoice
	Insert into #Temp
	Select  SerDet.SpareCode,
	"Item Name" = Items.ProductName,         
	"Quantity" = 
	(Case 	When @UOMdesc = 'UOM1' then dbo.sp_ser_Get_ReportingQty(Sum(IsNull(SerDet.Quantity,0)), 
					Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM1_Conversion End)      
				When @UOMdesc = 'UOM2' then dbo.sp_ser_Get_ReportingQty(Sum(IsNull(SerDet.Quantity,0)), 
					Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 
					Else 
					Items.UOM2_Conversion End)      
				Else 
					Sum(IsNull(SerDet.Quantity,0))End), 
	"Net Value (%c)" = Sum(IsNull(SerDet.NetValue,0))        
	From ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet, Items, Customer      
	Where SerDet.Sparecode = Items.Product_Code        
	And SerAbs.ServiceInvoiceid = SerDet.ServiceInvoiceid        
	And SerAbs.ServiceInvoiceDate between @FromDATE And @TODATE        
	And IsNull(SerAbs.Status,0) & 192 = 0        
	And IsNull(SerDet.SpareCode,'') <> ''
	And IsNull(SerAbs.ServiceInvoiceType,0) = 1
	And SerAbs.Customerid = Customer.Customerid      
	And SerAbs.Customerid like @CUST      
	Group By SerDet.SpareCode, Items.ProductName,   
	Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM   
	Order by 1
End
Begin
--Fetching the Fields From Temp Table To Display
	Select ProductCode,ProdName as "Item Name",Cast(Sum(Qty)as Varchar)
 	+ ' ' + 
 	Cast((Case 	When @UOMdesc = 'UOM1' then 
 						IsNull((Select Description From UOM Where UOM = Items.UOM1), '')
 				When @UOMdesc = 'UOM2' then 
 						IsNull((Select Description From UOM Where UOM = Items.UOM2), '')      
 				Else 
 						IsNull((Select Description From UOM Where UOM = Items.UOM),'') 
 				End) as varchar)  as "Quantity",  	
		
	Sum(Net) as "Net Value (%c)" From #Temp,Items 
 	Where Items.Product_Code = (#Temp.ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS)	
	Group By ProductCode,ProdName,Items.UOM1,Items.UOM2,Items.UOM
	Order By ProdName
	
	Drop Table #Temp
End
End -- Procedure End
