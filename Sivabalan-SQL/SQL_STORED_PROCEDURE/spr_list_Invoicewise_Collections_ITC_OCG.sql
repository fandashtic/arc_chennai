
CREATE Procedure spr_list_Invoicewise_Collections_ITC_OCG (@FromDate datetime,    
         @ToDate datetime,@CategoryGroupType Nvarchar(50))    
As  

Set DateFormat DMY  
Declare @CREDIT As NVarchar(50)  
Declare @CASH As NVarchar(50)  
Declare @CHEQUE As NVarchar(50)  
Declare @DD As NVarchar(50)  
Declare @OTHERS As NVarchar(50)  
Declare @INVOICE As NVarchar(50)  
Declare @RETAILINVOICE As NVarchar(50)  
Declare @SALESRETURNSALEABLE As NVarchar(50)  
Declare @SALESRETURNDAMAGES As NVarchar(50)  
Declare @SALESRETURN As NVarchar(50)  
Declare @INVOICEAMENDMENT As NVarchar(50)  
Declare @AllCG as nVarchar(100)

CREATE TABLE #tmpOUTPUT(
	[ID] [int] NOT NULL,
	[InvoiceID] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Doc Ref] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Invoice Date] [datetime] NULL,
	[Customer] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Salesman] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Category Group] [nvarchar](2550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Payment Mode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Net Value] [decimal](18, 6) NULL,
	[Balance] [decimal](18, 6) NULL,
	[Type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rounded Net Value] [decimal](18, 6) NULL)

Declare @TmpInvoiceId as Table (InvoiceId Int)
If @CategoryGroupType = N'' Or @CategoryGroupType = N'%'
Begin
	Set @CategoryGroupType = 'Operational'
End

Set @FromDate = Cast(Convert(Nvarchar(10),@FromDate,103) as DateTime)
Set @ToDate = Cast(Convert(Nvarchar(10),@ToDate,103) as DateTime)

If @CategoryGroupType = 'Regular'
Begin
	Insert Into @TmpInvoiceId (InvoiceId)
	select Distinct IA.InvoiceID From InvoiceDetail as ID With(Nolock),InvoiceAbstract as IA With(Nolock)
	Where
	ID.InvoiceID = IA.InvoiceID
	And IsNull(IA.Status, 0) & 128 = 0
	And IA.InvoiceType in (1, 3, 4)    
	And Convert(Nvarchar(10),IA.InvoiceDate ,103) Between @FromDate And @ToDate
--	And ID.GroupID in 
--	(select Distinct GroupID From ProductCategoryGroupAbstract Where Isnull(OCGType,0) = 0 And Isnull(Active,0) = 1)
End
Else If @CategoryGroupType = 'Operational'
Begin
	Insert Into @TmpInvoiceId (InvoiceId)
	select Distinct IA.InvoiceID From InvoiceDetail as ID With(Nolock),InvoiceAbstract as IA With(Nolock)
	Where
	ID.InvoiceID = IA.InvoiceID
	And IsNull(IA.Status, 0) & 128 = 0
	And IA.InvoiceType in (1, 3, 4)    
	And Convert(Nvarchar(10),IA.InvoiceDate ,103) Between @FromDate And @ToDate
--	And ID.GroupID in 
--	(select Distinct GroupID From ProductCategoryGroupAbstract Where Isnull(OCGType,0) = 1 And Isnull(Active,0) = 1)
End

Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)  
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)  
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)  
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)  
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice' , Default)  
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return - Saleable', Default)  
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return - Damages', Default)  
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)  
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)  
set @AllCG =dbo.LookupDictionaryItem(N'All Category Groups',Default)

Truncate Table #tmpOUTPUT
Insert Into #tmpOUTPUT
Select InvoiceID As "InvoiceID1", 
"InvoiceID" = case IsNUll(InvoiceAbstract.GSTFlag,0) when 0 then VoucherPrefix.Prefix +     
Cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') end,    
"Doc Ref" = InvoiceAbstract.DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Customer" = Customer.Company_Name,    
"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @OTHERS 
		Else IsNull(Salesman.Salesman_Name, N'') End,     
"Category Group" = dbo.Fn_GetCG_ITC_OCG(InvoiceAbstract.InvoiceID,(Case When @CategoryGroupType = 'Regular' Then 0 When @CategoryGroupType = 'Operational' Then 1 End)),
"Payment Mode" = case IsNull(PaymentMode,0)    
When 0 Then @CREDIT    
When 1 Then @CASH    
When 2 Then @CHEQUE    
When 3 Then @DD    
Else @CREDIT  
End,    
"Net Value" =  Case InvoiceType    
When 4 then    
0 - InvoiceAbstract.NetValue    
Else    
InvoiceAbstract.NetValue    
End,     
"Balance" = Case InvoiceType  
when 4 then  
0-(InvoiceAbstract.Balance)  
else  
InvoiceAbstract.Balance  
end,  
"Type" = Case InvoiceType    
When 1 then    
@INVOICE  
When 3 Then    
@INVOICEAMENDMENT  
When 4 Then    
@SALESRETURN  
End,  
"Rounded Net Value"  = 
Case InvoiceType    
When 4 then    
0-(NetValue + RoundOffAmount)
Else    
(NetValue + RoundOffAmount)
End
From InvoiceAbstract With(Nolock)
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join  Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Inner Join  VoucherPrefix  On VoucherPrefix.TranID = 'INVOICE'
Where 
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And    
InvoiceAbstract.InvoiceType in (1, 3, 4) And  
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate ,103) Between @FromDate And @ToDate
Union All    
    
Select InvoiceID As "InvoiceID1", 
"InvoiceID" = case IsNUll(InvoiceAbstract.GSTFlag,0) when 0 then VoucherPrefix.Prefix +     
Cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') end,    
"Doc Ref" = InvoiceAbstract.DocReference,    
"Invoice Date" = InvoiceAbstract.InvoiceDate,     
"Customer" = Customer.Company_Name,    
"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @Others
		Else IsNull(Salesman.Salesman_Name, N'') End,     

"Category Group" = dbo.Fn_GetCG_ITC_OCG(InvoiceAbstract.InvoiceID,(Case When @CategoryGroupType = 'Regular' Then 0 When @CategoryGroupType = 'Operational' Then 1 End)),
"Payment Mode" = case IsNull(PaymentMode,0)    
When 0 Then @CREDIT  
When 1 Then @OTHERS  
End,    
"Net Value" = Case InvoiceType    
When 5 then    
0 - IsNull(InvoiceAbstract.NetValue, 0)  
When 6 then    
0 - IsNull(InvoiceAbstract.NetValue, 0)  
Else    
IsNull(InvoiceAbstract.NetValue, 0)  
End,     
"Balance" = Case InvoiceType    
When 5 then    
0 - IsNull(InvoiceAbstract.Balance, 0)  
When 6 then    
0 - IsNull(InvoiceAbstract.Balance, 0)  
Else    
IsNull(InvoiceAbstract.Balance, 0)  
End,     
"Type" = Case InvoiceType    
When 5 then    
@SALESRETURNSALEABLE  
When 6 then    
@SALESRETURNDAMAGES  
Else    
@RETAILINVOICE  
End,  
"Rounded Net Value"  = 
Case InvoiceType    
When 5 then    
0-(NetValue + RoundOffAmount)
When 6 then    
0-(NetValue + RoundOffAmount)
Else    
(NetValue + RoundOffAmount)
End
From InvoiceAbstract With(Nolock)
Left Outer Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join  Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID    
Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE'
Where 
IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And    
InvoiceAbstract.InvoiceType In (2, 5, 6) And  
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate ,103) Between @FromDate And @ToDate
Order By "Type", "InvoiceID"   

Delete From #tmpOUTPUT Where Id Not In (Select Distinct InvoiceId From @TmpInvoiceId)

Select * from #tmpOUTPUT

Drop Table #tmpOUTPUT
Delete From @TmpInvoiceId

