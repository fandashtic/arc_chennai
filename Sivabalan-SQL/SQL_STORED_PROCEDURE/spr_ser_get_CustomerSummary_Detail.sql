CREATE procedure spr_ser_get_CustomerSummary_Detail (@CustID varchar(30), @FromDate DateTime, @ToDate DateTime)
as
begin 

Declare @FromMonth int
Declare @ToMonth int
Declare @CurrMonth int
Declare @Query varchar(1000)
Declare @ItemCode varchar(50)
Declare @Month varchar(15)
Declare @Count int

Declare @DateValue Varchar(100)
Declare @ProductName varchar(100)
Declare @Serial Int
Declare @ColNames Varchar(8000)

Set @FromMonth = datepart(month, @FromDate)
Set @ToMonth = datepart(month, @FromDate) + datediff(m, @FromDate, @ToDate)
Set @Count = 0
Set @CurrMonth = @FromMonth
Set @ColNames=N''

Create table #CustomerSummary_Abs
(
	Serial Int Identity(1, 1),
	DateValue varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Item varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Qty Decimal(18,6),
	Value Decimal(18,6),
	Amount Decimal(18,6)
)

Create table #CustomerSummary_Results
(
	DateValue varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Item varchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Qty Decimal(18,6),
	Value Decimal(18,6)
)
	While  @CurrMonth <= @ToMonth
	Begin
		Set @Month = convert(varchar, dateadd ( m, @Count, @FromDate) , 106)
		Set @Month = substring( @Month, 4, 15)

		Set @Query  = N'alter table #CustomerSummary_Abs add [' + @Month + N'] Decimal(18,6)'
		Exec (@Query)

		Set @Query  = N'alter table #CustomerSummary_Results add [' + @Month + N'] Decimal(18,6)'
		Exec (@Query)

		Set @ColNames=@ColNames + N'['+ @Month + N'],'
		Set @CurrMonth = @CurrMonth + 1
		Set @Count = @Count + 1
	End
Set @ColNames=Left(@ColNames,len(@ColNames)-1)

Insert into #CustomerSummary_Abs (DateValue, Item,Qty,Value,Amount) 
---Invoice 
Select distinct substring(Convert(Varchar,IA.InvoiceDate,106),4,15), It.ProductName,Sum(IDt.Quantity),Idt.SalePrice,
sum(case IA.InvoiceType  when 4 then -IDt.Amount
			 when 5 then -IDt.Amount
			 when 6 then -IDt.Amount
			 else IDt.Amount end)
From Items It, InvoiceAbstract IA, InvoiceDetail IDt
Where IDt.InvoiceID = IA.InvoiceID 
and IA.CustomerID like @CustID
and It.Product_Code = IDt.Product_Code 
and IA.InvoiceDate between @FromDate and @ToDate
and IsNull(IA.Status,0) & 192 = 0
Group by It.Product_Code,It.ProductName,substring(Convert(Varchar,IA.InvoiceDate,106),4,15),Idt.SalePrice

union

--Service Invoice

Select distinct substring(Convert(Varchar,SerAbs.ServiceInvoiceDate,106),4,15), 
It.ProductName,Sum(IsNull(SerDet.Quantity,0)),SerDet.Price,Sum(IsNull(SerDet.NetValue,0))
From Items It, ServiceInvoiceAbstract SerAbs, ServiceInvoiceDetail SerDet
Where SerDet.ServiceInvoiceID = SerAbs.ServiceInvoiceID 
and SerAbs.CustomerID like @CustID
and It.Product_Code = SerDet.SpareCode
and SerAbs.ServiceInvoiceDate between @FromDate and @ToDate
and IsNull(SerAbs.Status,0) & 192 = 0
and IsNull(SpareCode,'') <>''
and IsNull(SerAbs.ServiceInvoiceType,0) = 1
Group by It.Product_Code,It.ProductName,substring(Convert(Varchar,SerAbs.ServiceInvoiceDate,106),4,15),SerDet.Price

Declare CustomerSummary Cursor 
For
Select Serial, DateValue,Item from #CustomerSummary_Abs

Open CustomerSummary
Fetch next from CustomerSummary into @Serial, @DateValue,@ProductName

While @@FETCH_STATUS = 0
Begin 
	Set @Count = 0
	Set @CurrMonth = @FromMonth
		While @CurrMonth <= @ToMonth
		Begin
			Set @Month = convert(varchar, dateadd ( m, @Count, @FromDate) , 106)
			Set @Month = substring( @Month, 4, 15)
			Set @Query = N'
			update #CustomerSummary_Abs 
			Set [' + ( @Month ) + N'] = (
				select Amount from #CustomerSummary_Abs
				where 	item='''+ @ProductName + ''' and 
					datevalue='''+ @Month + '''and 
					Serial = ''' + Cast (@Serial As VarChar) + '''
					)
			Where		
				item='''+ @ProductName + ''' and 
				datevalue='''+ @Month + ''' and 
				Serial = ''' + Cast (@Serial As VarChar) + ''''
			Exec (@Query)

			Set @Query = N'update #CustomerSummary_Abs 
						  set [' + ( @Month ) + N'] = Null
						  where [' + ( @Month ) + N'] = 0'
			Exec (@Query)

			Set @CurrMonth = @CurrMonth + 1
			Set @Count = @Count + 1
		End
	Fetch next from CustomerSummary into @Serial, @datevalue,@productname
End

Close CustomerSummary
Deallocate CustomerSummary

Set @Query = N'Insert into #CustomerSummary_Results Select DateValue,Item,Qty,Value,'+ @ColNames + N' From #CustomerSummary_Abs'
Exec (@Query)
Select * From #CustomerSummary_Results
End

Drop Table #CustomerSummary_Abs

Drop Table #CustomerSummary_Results


