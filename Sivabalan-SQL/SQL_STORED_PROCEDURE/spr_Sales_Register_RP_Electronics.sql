CREATE Procedure spr_Sales_Register_RP_Electronics(@CustomerID nVarChar(2550),
												   @TaxSlab nVarChar(2550),
												   @FromDate DateTime,
												   @ToDate DateTime,
												   @FromInvNo Int,
												   @ToInvNo Int)
As
Declare @Prefix nVarChar(255)
Declare @Count Int
Declare @Count1 Int
Declare @i Int
Declare @Tax Decimal(18, 6)
Declare @TempSql nVarchar(4000)
Declare @j Int
Declare @inv Int
Declare @Type nVarChar(10)
Declare @SalesVal Decimal(18, 6)
Declare @TaxVal Decimal(18, 6)
Declare @Delimeter as Char(1)  

If @ToInvNo <= 0
Set @ToInvNo = 2147483647

Set @Delimeter = Char(15)  
Set @i = 1

Create table #tmpCus(CustID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )  
Create table #tmpTSlab(TDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )  
Create Table #TempSix(Tax_Code Int)

If @CustomerID = N'%'   
   Insert into #tmpCus select CustomerID from Customer Union select CustomerID from Cash_Customer Union Select Cast(-1 As nVarChar)
Else  
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter) Union Select Cast(-1 As nVarChar)
  
If @TaxSlab = N'%'  
   Insert into #tmpTSlab select Tax_Description From Tax
Else  
   Insert into #tmpTSlab select * from dbo.sp_SplitIn2Rows(@TaxSlab, @Delimeter)  

Insert InTo #TempSix Select Tax_Code From Tax Where Tax_Description In (Select TDesc From #tmpTSlab)

If @TaxSlab = N'%'
Begin
	Insert InTo #TempSix Values (-2)
End

Select @Prefix = Prefix From VoucherPrefix Where TranID Like N'INVOICE'

Create Table #TempOne ([InvoiceID] Int, [Date] DateTime, [Serial No] nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS , 
	[Document No] nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS , [Customer Name] nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS , [Gross Value] Decimal(18, 6),
	[Item Based Scheme Discount] Decimal(18, 6), [Gross Amount] Decimal(18, 6), [Trade Discount] Decimal(18, 6),
	[Gross  Amount] Decimal(18, 6), [Addl Discount] Decimal(18, 6), [Gross   Amount] Decimal(18, 6), 
	[Freight] Decimal(18, 6), [Gross] Decimal(18, 6))

Select Distinct Tax = TaxCode, Type = N'L' InTo #TempTwo 
From InvoiceAbstract ia, InvoiceDetail ide 
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
--ia.InvoiceType Not In(2) And 
IsNull(ide.TaxCode, 0) > 0 And IsNull(ia.Status, 0) & 192 = 0 

Insert Into #TempTwo Select Distinct TaxCode2, N'K'
From InvoiceAbstract ia, InvoiceDetail ide 
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
--ia.InvoiceType Not In(2) And 
IsNull(ide.TaxCode2, 0) > 0 And IsNull(ia.Status, 0) & 192 = 0 

Insert Into #TempTwo Select Distinct (IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)), N'J'
From InvoiceAbstract ia, InvoiceDetail ide 
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
--ia.InvoiceType Not In(2) And 
(IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = 0 And IsNull(ia.Status, 0) & 192 = 0 

Insert Into #TempTwo Select Distinct 0, N'I'

Select [ID] = Identity(Int, 1, 1), Tax, Type InTo #TempThree From #TempTwo 
Order By Type Desc

Select @Count = Count(Tax) From #TempThree

Select distinct ia.InvoiceID InTo #TempFour 
From InvoiceAbstract ia, InvoiceDetail ide
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
--ia.InvoiceType Not In (2) And 
IsNull(ia.Status, 0) & 192 = 0 

Select [ID] = Identity(Int, 1, 1), InvoiceID InTo #TempFive From #TempFour

Select @Count1 = Count(*) From #TempFive

While @Count >= @i
Begin
  Select @Type = Type, @Tax = Tax From #TempThree Where [ID] = @i
  
  If @Type = N'L'
  Begin
  	Set @TempSql = N'Alter Table #TempOne Add [LST ' + Cast(@Tax As nVarChar) + N'% Sales] 
	Decimal(18, 6) Default(0) Not Null'
	Exec sp_executesql @TempSql

	Set @TempSql = N'Alter Table #TempOne Add [LST ' + Cast(@Tax As nVarChar) + N'% Tax] 
	Decimal(18, 6) Default(0) Not Null'
  	Exec sp_executesql @TempSql
  End

  If @Type = N'K'
  Begin
  	Set @TempSql = N'Alter Table #TempOne Add [CST ' + Cast(@Tax As nVarChar) + N'% Sales] 
	Decimal(18, 6) Default(0) Not Null'
	Exec sp_executesql @TempSql

	Set @TempSql = N'Alter Table #TempOne Add [CST ' + Cast(@Tax As nVarChar) + N'% Tax] 
	Decimal(18, 6) Default(0) Not Null'
  	Exec sp_executesql @TempSql
  End

  If @Type = N'J'
  Begin
  	Set @TempSql = N'Alter Table #TempOne Add [Exempted Sales] 
	Decimal(18, 6) Default(0) Not Null'
	Exec sp_executesql @TempSql
  End

  If @Type = N'I'
  Begin
  	Set @TempSql = N'Alter Table #TempOne Add [Net Value] 
	Decimal(18, 6) Default(0) Not Null, [R/O] 
	Decimal(18, 6) Default(0) Not Null, [Rounded Net Value] 
	Decimal(18, 6) Default(0) Not Null'
	Exec sp_executesql @TempSql
  End

  Set @j = 1
  While @Count1 >= @j

  Begin
    Select @inv = InvoiceID From #TempFive Where [ID] = @j

    If Not Exists(Select * From #TempOne Where InvoiceID = @inv)
    Begin
		If @Type = N'L'
		Begin
	      Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No], 
	      [Document No], [Customer Name], [Gross Value], [Item Based Scheme Discount], 
	      [Gross Amount], [Trade Discount], [Gross  Amount], [Addl Discount], [Gross   Amount], 
	      [Freight], [Gross], [LST ' + Cast(@Tax As nVarChar) + N'% Sales], 
	      [LST ' + Cast(@Tax As nVarChar) + N'% Tax])
	      Select ia.InvoiceID, ia.InvoiceDate, N''' + @Prefix + ''' + Cast(ia.DocumentID As nVarChar),
	      ia.DocReference, IsNull(c.Company_Name, ''Others''), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)),
	      -- (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GrossValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.Freight, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0) - IsNull(ide.STPayable, 0)), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.STPayable, 0)) 
		  From InvoiceAbstract ia, InvoiceDetail ide, Customer c, Tax t
		  Where ia.CustomerID *= c.CustomerID And 
	      ia.InvoiceID = ide.InvoiceID And ide.TaxID = t.Tax_Code And 
	      (Case IsNull(ia.CustomerID, ''0'') When ''0'' Then ''-1'' Else IsNull(ia.CustomerID, ''0'') End) In (Select CustID From #tmpCus) And t.Tax_Description Like 
	      N''' + @TaxSlab + ''' And ia.InvoiceDate Between ''' + Cast(@FromDate As nVarChar)
	      + ''' And ''' + Cast(@ToDate As nVarChar) + ''' And ia.DocumentID Between ' + 
	      Cast(@FromInvNo As nVarChar) + N' And ' + Cast(@ToInvNo As nVarChar) + N' And ide.TaxCode = ' +
	      Cast(@Tax As nVarChar) + N' And 
		  -- ia.InvoiceType Not In (2) And 
	      ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' And IsNull(ia.Status, 0) & 192 = 0 
          Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference, 
          c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue, 
          ia.NetValue, ia.Freight, ia.InvoiceType'
		End
		Else If @Type = N'K'
		Begin
	      Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No], 
	      [Document No], [Customer Name], [Gross Value], [Item Based Scheme Discount], 
	      [Gross Amount], [Trade Discount], [Gross  Amount], [Addl Discount], [Gross   Amount], 
	      [Freight], [Gross], [CST ' + Cast(@Tax As nVarChar) + N'% Sales], 
	      [CST ' + Cast(@Tax As nVarChar) + N'% Tax])
	      Select ia.InvoiceID, ia.InvoiceDate, N''' + @Prefix + ''' + Cast(ia.DocumentID As nVarChar),
	      ia.DocReference, IsNull(c.Company_Name, ''Others''), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)),
	      -- (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GrossValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.Freight, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0) - IsNull(ide.CSTPayable, 0)), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.CSTPayable, 0)) 
		  From InvoiceAbstract ia, InvoiceDetail ide, Customer c, Tax t
          Where ia.CustomerID *= c.CustomerID And 
	      ia.InvoiceID = ide.InvoiceID And t.Tax_Code = ide.TaxID And 
	      (Case IsNull(ia.CustomerID, ''0'') When ''0'' Then ''-1'' Else IsNull(ia.CustomerID, ''0'') End) In (Select CustID From #tmpCus) And t.Tax_Description Like 
	      N''' + @TaxSlab + ''' And ia.InvoiceDate Between ''' + Cast(@FromDate As nVarChar)
	      + ''' And ''' + Cast(@ToDate As nVarChar) + ''' And ia.DocumentID Between ' + 
	      Cast(@FromInvNo As nVarChar) + N' And ' + Cast(@ToInvNo As nVarChar) + N' And ide.TaxCode2 = ' +
	      Cast(@Tax As nVarChar) + N' And 
          -- ia.InvoiceType Not In (2) And 
	      ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' And IsNull(ia.Status, 0) & 192 = 0 
          Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference, 
          c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue, 
          ia.NetValue, ia.Freight, ia.InvoiceType'
		End
		Else If @Type = N'J'
		Begin
	      Set @TempSql = N'Insert InTo #TempOne ([InvoiceID], [Date], [Serial No], 
	      [Document No], [Customer Name], [Gross Value], [Item Based Scheme Discount], 
	      [Gross Amount], [Trade Discount], [Gross  Amount], [Addl Discount], [Gross   Amount], 
	      [Freight], [Gross], [Exempted Sales])
	      Select ia.InvoiceID, ia.InvoiceDate, N''' + @Prefix + ''' + Cast(ia.DocumentID As nVarChar),
	      ia.DocReference, IsNull(c.Company_Name, ''Others''), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0), 
		  (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)),
	      -- (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GrossValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0))),
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.DiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * ((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.Freight, 0), 
          (Case ia.InvoiceType When 4 Then -1 Else 1 End) * (((IsNull(ia.GoodsValue, 0) - (Sum(IsNull(ide.SCHEMEDISCAMOUNT, 0) +  IsNull(ide.SPLCATDISCAMOUNT, 0)))) - IsNull(ia.DiscountValue, 0)) - IsNull(ia.AddlDiscountValue, 0)) + IsNull(ia.Freight, 0), 
	      (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.Amount, 0)) 
          -- (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(IsNull(ide.STPayable, 0)) 
		  From InvoiceAbstract ia, InvoiceDetail ide, Customer c, 
          -- Tax t, 
           (Select distinct InvoiceID From InvoiceDetail Where IsNull(TaxID, -2) In (Select Tax_Code From #TempSix) ) t
		  Where ia.CustomerID *= c.CustomerID And 
	      ia.InvoiceID = ide.InvoiceID And 
        ide.InvoiceID = t.InvoiceID And
          -- t.Tax_Code = ide.TaxID And 
	      (Case IsNull(ia.CustomerID, ''0'') When ''0'' Then ''-1'' Else IsNull(ia.CustomerID, ''0'') End) In (Select CustID From #tmpCus) And 
		  -- t.Tax_Description Like N''' + @TaxSlab + ''' And 
          ia.InvoiceDate Between ''' + Cast(@FromDate As nVarChar)
	      + ''' And ''' + Cast(@ToDate As nVarChar) + ''' And ia.DocumentID Between ' + 
	      Cast(@FromInvNo As nVarChar) + N' And ' + Cast(@ToInvNo As nVarChar) + N' And 
          (IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = ' +
	      Cast(@Tax As nVarChar) + N' And 
		  -- ia.InvoiceType Not In (2) And 
	      ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' And IsNull(ia.Status, 0) & 192 = 0 
          Group By ia.InvoiceID, ia.InvoiceDate, ia.DocumentID, ia.DocReference, 
          c.Company_Name, ia.GoodsValue, ia.GrossValue, ia.DiscountValue, ia.AddlDiscountValue, 
          ia.NetValue, ia.Freight, ia.InvoiceType'
		End
		Else If @Type = N'I'
		Begin
			Set @TempSql = N''
        End
    Exec sp_executesql @TempSql
	End
	Else
	Begin
		If @Type = N'L'
		Begin
            Set @SalesVal = 0
			Set @TaxVal = 0

			Select @SalesVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.Amount - ide.STPayable), 
            @TaxVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.STPayable)
			From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId
            And ide.TaxCode = @Tax And ia.InvoiceID = @inv Group By ia.InvoiceType
            
            Set @TempSql = N'Update #TempOne Set [LST ' + Cast(@Tax As nVarChar) + N'% Sales] = 
			[LST ' + Cast(@Tax As nVarChar) + N'% Sales] + ' + Cast(@SalesVal As nVarChar) + N', 
			[LST ' + Cast(@Tax As nVarChar) + N'% Tax] = [LST ' + Cast(@Tax As nVarChar) + N'% Tax] + ' 
			+ Cast(@TaxVal As nVarChar) + N' Where InvoiceID = ' + Cast(@inv as nVarChar) + ''

		End
		Else If @Type = N'K'
		Begin
            Set @SalesVal = 0
			Set @TaxVal = 0
			Select @SalesVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.Amount - ide.CSTPayable), 
            @TaxVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.CSTPayable)
			From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId
            And ide.TaxCode2 = @Tax And ia.InvoiceID = @inv Group By ia.InvoiceType
            
            Set @TempSql = N'Update #TempOne Set [CST ' + Cast(@Tax As nVarChar) + N'% Sales] = 
			[CST ' + Cast(@Tax As nVarChar) + N'% Sales] + ' + Cast(@SalesVal As nVarChar) + N', 
			[CST ' + Cast(@Tax As nVarChar) + N'% Tax] = [CST ' + Cast(@Tax As nVarChar) + N'% Tax] + ' 
			+ Cast(@TaxVal As nVarChar) + N' Where InvoiceID = ' + Cast(@inv as nVarChar) + ''
		End
        Else If @Type = N'J'
		Begin
            Set @SalesVal = 0
			Set @TaxVal = 0

			Select @SalesVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.Amount)
            -- @TaxVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * Sum(ide.STPayable)
			From InvoiceAbstract ia, InvoiceDetail ide Where ia.InvoiceID = ide.InvoiceId
            And (IsNull(ide.TaxCode, 0) + IsNull(ide.TaxCode2, 0)) = @Tax And 
			ia.InvoiceID = @inv Group By ia.InvoiceType
            
            Set @TempSql = N'Update #TempOne Set [Exempted Sales] = 
			[Exempted Sales] + ' + Cast(@SalesVal As nVarChar) + N'
			Where InvoiceID = ' + Cast(@inv as nVarChar) + ''
		End
        Else If @Type = N'I'
		Begin
            Set @SalesVal = 0
			Set @TaxVal = 0

			Select @SalesVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.NetValue, 0),
            @TaxVal = (Case ia.InvoiceType When 4 Then -1 Else 1 End) * IsNull(ia.RoundOffAmount, 0)
			From InvoiceAbstract ia Where ia.InvoiceID = @inv
            
            Set @TempSql = N'Update #TempOne Set [Net Value] = 
			[Net Value] + ' + Cast(@SalesVal As nVarChar) + N',
			[R/O] = [R/O] + ' + Cast(@TaxVal As nVarChar) + N',
			[Rounded Net Value] = ' + Cast(@SalesVal + @TaxVal As nVarChar) + N'
			Where InvoiceID = ' + Cast(@inv as nVarChar) + ''
		End
		Exec sp_executesql @TempSql
	End
    Set @j = @j + 1	
  End
  Set @i = @i + 1
End

Select * From #TempOne order by cast(Replace([Serial No],@Prefix,'')as int)

Drop Table #TempOne
Drop Table #TempTwo
Drop Table #TempThree
Drop Table #TempFour
Drop Table #TempFive
Drop Table #tmpCus
Drop Table #tmpTSlab
Drop Table #TempSix


