
Create Procedure spr_ser_Partywise_VAT_Summary (@Fromdate Datetime, @Todate Datetime)
AS  
Declare @StrSql  Varchar(8000) 	
Declare @Tax Varchar(128)
Declare @DynamicSQL nVarchar(4000)
Declare @SerSql nVarchar(4000)
Declare @InvCustId Varchar(30)
Declare @InvCustName Varchar(300)
Declare @InvTaxAmt Decimal(18,6)
Declare @InvPerTax Varchar(128)

Create Table #InvTemp(CustomerId Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName Varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
PerTax Varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,TaxAmt Decimal(18,6))

Create Table #InvTemp1(CustomerId Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName Varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
TaxPercent Varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,TotalAmount Decimal(18,6))

Create Table #TempRegister(CustomerId Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName Varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into #InvTemp
Select InvAbs.CustomerId,Customer.Company_Name,(InvDet.TaxCode + InvDet.TaxCode2), 
IsNull(Sum(Case when InvAbs.InvoiceType in (4,5,6) 
then 0 - (InvDet.StPayable + InvDet.CstPayable) Else 
InvDet.StPayable+InvDet.CstPayable End),0) 
From InvoiceDetail InvDet,InvoiceAbstract InvAbs,Customer 
Where Customer.CustomerID = InvAbs.CustomerID 
And InvDet.InvoiceId = InvAbs.InvoiceId 
And InvAbs.InvoiceType Not In (4, 5, 6) 
And InvDet.TaxCode + InvDet.TaxCode2 <> 0 
And (InvAbs.Status & 128) = 0 
And InvAbs.InvoiceDate Between @FromDate and @ToDate 
Group by Customer.Company_Name,InvAbs.CustomerID,InvDet.TaxCode + InvDet.TaxCode2
Union
Select InvAbs.CustomerId,"CustomerName" = (Case When Customer.Company_Name Is Null 
then "Other Customers" 
Else Customer.Company_Name End),
(InvDet.TaxCode + InvDet.TaxCode2),
0 - IsNull(Sum(StPayable+CstPayable),0)
From Invoiceabstract InvAbs, Customer, InvoiceDetail InvDet
Where Customer.CustomerID = InvAbs.CustomerID 
And InvDet.InvoiceId = InvAbs.InvoiceId 
And InvAbs.InvoiceType In (4, 5, 6) 
And InvDet.TaxCode + InvDet.TaxCode2 <> 0 
And (InvAbs.Status & 128) = 0 
And InvAbs.InvoiceDate Between @FromDate and @ToDate 
Group by InvAbs.CustomerID,Customer.company_name,InvDet.TaxCode+InvDet.TaxCode2
Union
Select SerAbs.CustomerId,Customer.Company_Name,SerDet.SaleTax,
IsNull(Sum(SerDet.LstPayable + SerDet.CstPayable),0)
From ServiceInvoiceAbstract SerAbs,ServiceInvoiceDetail SerDet,Customer
Where Customer.CustomerId = SerAbs.CustomerId
And SerAbs.ServiceInvoiceId = SerDet.ServiceInvoiceId
And SerDet.SaleTax <> 0 
And IsNull(ServiceInvoiceType,0) = 1
And IsNull(SerAbs.Status,0) & 192 = 0
And SerAbs.ServiceInvoiceDate Between @FromDate and @ToDate 
Group by SerAbs.CustomerID,Customer.Company_Name,SerDet.SaleTax


Insert into #InvTemp1
Select CustomerId,CustomerName,PerTax,Sum(TaxAmt) 
From #InvTemp 
Group By CustomerId,CustomerName,PerTax

Declare PercentageTax Cursor For
Select Distinct(TaxPercent) From #InvTemp1 Order by TaxPercent
Open PercentageTax
Fetch From PercentageTax Into @Tax
While @@Fetch_Status =0             
Begin   
Set @DynamicSQL = 'Alter Table #TempRegister Add [' + @Tax + '%] Decimal(18,6) Default 0'              
Exec Sp_Executesql @DynamicSQL                
Fetch Next From PercentageTax Into @Tax
End
Close PercentageTax
DeAllocate PercentageTax

Set @SerSql = 'Alter Table #TempRegister Add Total Decimal(18,6)'
Exec Sp_Executesql @SerSql 
               
Insert into #TempRegister(CustomerID,CustomerName) 
Select Distinct CustomerId,CustomerName From #InvTemp1

Declare InvTaxReg Cursor For              
Select CustomerId,CustomerName,TaxPercent,TotalAmount From #InvTemp1
Open InvTaxReg 
Fetch From InvTaxReg Into @InvCustId,@InvCustName,@InvPerTax,@InvTaxAmt                           
While @@Fetch_Status =0             
Begin        
Set @DynamicSQL = 'Update #TempRegister Set 
Total = (Select Sum(TotalAmount) 
From #InvTemp1 
Where Customerid = ''' + Cast(@InvCustId  as VarChar) + '''),
[' + @InvPerTax + '%] = IsNull(' + CAST(@InvTaxAmt as VarChar) + ',0)  
Where CustomerId = ''' + Cast(@InvCustId  as VarChar) + ''''
Exec sp_executesql @DynamicSQL
Fetch Next From InvTaxReg Into @InvCustId,@InvCustName,@InvPerTax,@InvTaxAmt           
End             
Close InvTaxReg              
DeAllocate InvTaxReg              

Select * From #TempRegister 

Drop Table #InvTemp
Drop Table #InvTemp1
Drop Table #TempRegister

