CREATE Procedure spr_sales_vat_report
                                    (@FromDate DateTime,
                                     @ToDate DateTime)
As

Declare @Prefix nVarChar(255)
Declare @Count Int
Declare @i Int
Declare @Tax Decimal(18, 6)
Declare @TempSql nVarchar(4000)
Declare @Count1 Int
Declare @j Int
Declare @inv Int

Set @i = 1


Select @Prefix = Prefix From VoucherPrefix Where TranID Like N'INVOICE'

Create Table #TempOne ([InvoiceID] Int, [Date] DateTime, [Customer Name] nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  [TIN No] nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Inv No] nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Select Distinct Tax = (TaxCode + TaxCode2) InTo #TempTwo 
From InvoiceAbstract ia, InvoiceDetail ide 
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
  ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 192 = 0 

Select [ID] = Identity(Int, 1, 1), Tax InTo #TempThree From #TempTwo
--Select * from #TempThree
Select @Count = Count(Tax) From #TempThree

Select distinct ia.InvoiceID InTo #TempFour 
From InvoiceAbstract ia, InvoiceDetail ide
Where ia.InvoiceID = ide.InvoiceID And ia.InvoiceDate Between @FromDate And @ToDate And
  ia.InvoiceType Not In (2) And IsNull(ia.Status, 0) & 192 = 0 
Select [ID] = Identity(Int, 1, 1), InvoiceID InTo #TempFive From #TempFour
--Select * From #TempFour
--Select * From #TempFive
Select @Count1 = Count(*) From #TempFive

While @Count >= @i
Begin
  Select @Tax = Tax From #TempThree Where [ID] = @i

  Set @TempSql = N'Alter Table #TempOne Add [' + Cast(@Tax As nVarChar) + N'% VAT] Decimal(18, 6) Default(0) Not Null'

  Exec sp_executesql @TempSql

  Set @j = 1
  While @Count1 >= @j

  Begin
    Select @inv = InvoiceID From #TempFive Where [ID] = @j
    If Not Exists(Select * From #TempOne Where InvoiceID = @inv)
    Begin
      Set @TempSql = 
        N'Insert InTo #TempOne ([InvoiceID], [Date], [Customer Name], [TIN No],
        [Inv No], [' + Cast(@Tax As nVarChar) + N'% VAT] ) Select ia.InvoiceID, ia.InvoiceDate, 
        c.Company_Name, c.TIN_Number, N''' + @Prefix + ''' + Cast(DocumentID As nVarChar),
        (Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * IsNull((Select Sum(IsNull(Amount, 0)) - (Sum(IsNull(STPayable, 0)) + 
        Sum(IsNull(CSTPayable, 0))) From InvoiceDetail Where InvoiceID = ia.InvoiceID And
        (TaxCode + TaxCode2) = ' + Cast(@Tax As nVarChar) + N'), 0) From InvoiceAbstract ia, Customer c Where
        ia.CustomerID = c.CustomerID And ia.InvoiceDate Between ''' + Cast(@FromDate As nVarChar)
        + ''' And ''' + Cast(@ToDate As nVarChar) + ''' And ia.InvoiceType Not In (2) And 
        ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' And IsNull(ia.Status, 0) & 192 = 0 '

    End
    Else
    Begin
      Set @TempSql = N'Update #TempOne Set [' + Cast(@Tax As nVarChar) + N'% VAT] = 
        IsNull((Select (Case IsNull(InvoiceType, 1) When 4 Then -1 Else 1 End) 
        From InvoiceAbstract Where InvoiceId = ' 
        + Cast(@inv As nVarChar)+ N'), 1) *
        ([' + Cast(@Tax As nVarChar) + N'% VAT]
        + IsNull((Select Sum(IsNull(Amount, 0)) - (Sum(IsNull(STPayable, 0)) + 
        Sum(IsNull(CSTPayable, 0))) From InvoiceDetail Where 
        InvoiceID = ' +  Cast(@inv As nVarChar) + N' And
        (TaxCode + TaxCode2) = ' + Cast(@Tax As nVarChar) + N'), 0)) Where InvoiceID = ' 
        + Cast(@inv As nVarChar)+ ''

    End
    Exec sp_executesql @TempSql
    Set @j = @j + 1
  End
  
  Set @i = @i + 1
End

If Not Exists (Select * From #TempThree Where Tax = 0)
Begin
  Set @TempSql = 
    N'Alter Table #TempOne Add [' + Cast(.000000 As nVarChar) + N'% VAT] Decimal(18, 6) 
    Default(0) Not Null'
  Exec sp_executesql @TempSql
End

If Not Exists (Select * From #TempThree Where Tax = 4)
Begin
  Set @TempSql = 
    N'Alter Table #TempOne Add [' + Cast(4.000000 As nVarChar) + N'% VAT] Decimal(18, 6) 
    Default(0) Not Null'
  Exec sp_executesql @TempSql
End

If Not Exists (Select * From #TempThree Where Tax = 12.5)
Begin
  Set @TempSql = 
    N'Alter Table #TempOne Add [' + Cast(12.500000 As nVarChar) + N'% VAT] Decimal(18, 6) 
    Default(0) Not Null'
  Exec sp_executesql @TempSql
End

Set @TempSql = 
  N'Alter Table #TempOne Add [Total Amount] Decimal(18, 6) 
  Default(0) Not Null'
  Exec sp_executesql @TempSql

Set @TempSql = 
  N'Update #TempOne Set [Total Amount] = [' + Cast(4.000000 As nVarChar) + N'% VAT] + 
  [' + Cast(12.500000 As nVarChar) + N'% VAT]'
  Exec sp_executesql @TempSql

Set @i = 1
While @Count >= @i
Begin
  Select @Tax = Tax From #TempThree Where [ID] = @i

  If @Tax = 0
  Begin
    GOTO skipp
  End

  Set @TempSql = N'Alter Table #TempOne Add [' + Cast(@Tax As nVarChar) + N'% TAX VAT] Decimal(18, 6) Default(0) Not Null'

  Exec sp_executesql @TempSql

  Set @j = 1
  While @Count1 >= @j

  Begin
    Select @inv = InvoiceID From #TempFive Where [ID] = @j
    If Not Exists(Select * From #TempOne Where InvoiceID = @inv)
    Begin
      Set @TempSql = 
        N'Insert InTo #TempOne ([InvoiceID], [Date], [Customer Name], [TIN No],
        [Inv No], [' + Cast(@Tax As nVarChar) + N'% TAX VAT] ) Select ia.InvoiceID, ia.InvoiceDate, 
        c.Company_Name, c.TIN_Number, N''' + @Prefix + ''' + Cast(DocumentID As nVarChar),
        (Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End) * IsNull((Select Sum(IsNull(STPayable, 0)) + 
        Sum(IsNull(CSTPayable, 0)) From InvoiceDetail Where InvoiceID = ia.InvoiceID And
        (TaxCode + TaxCode2) = ' + Cast(@Tax As nVarChar) + N'), 0) From InvoiceAbstract ia, Customer c Where
        ia.CustomerID = c.CustomerID And ia.InvoiceDate Between ''' + Cast(@FromDate As nVarChar)
        + ''' And ''' + Cast(@ToDate As nVarChar) + ''' And ia.InvoiceType Not In (2) And 
        ia.InvoiceID = ' + Cast(@inv As nVarChar) + N' And IsNull(ia.Status, 0) & 192 = 0 '

    End
    Else
    Begin
      Set @TempSql = N'Update #TempOne Set [' + Cast(@Tax As nVarChar) + N'% TAX VAT] = 
        IsNull((Select (Case IsNull(InvoiceType, 1) When 4 Then -1 Else 1 End) 
        From InvoiceAbstract Where InvoiceId = ' 
        + Cast(@inv As nVarChar)+ N'), 1) * ([' + Cast(@Tax As nVarChar) + N'% TAX VAT]
        + IsNull((Select Sum(IsNull(STPayable, 0)) + 
        Sum(IsNull(CSTPayable, 0)) From InvoiceDetail Where InvoiceID = ' +  Cast(@inv As nVarChar) + N' And
        (TaxCode + TaxCode2) = ' + Cast(@Tax As nVarChar) + N'), 0)) Where InvoiceID = ' 
        + Cast(@inv As nVarChar)+ ''

    End
    Exec sp_executesql @TempSql
    Set @j = @j + 1
  End

  skipp:
    Set @i = @i + 1
End

If Not Exists (Select * From #TempThree Where Tax = 4)
Begin
  Set @TempSql = 
    N'Alter Table #TempOne Add [' + Cast(4.000000 As nVarChar) + N'% TAX VAT] Decimal(18, 6) 
    Default(0) Not Null'
  Exec sp_executesql @TempSql
End

If Not Exists (Select * From #TempThree Where Tax = 12.5)
Begin
  Set @TempSql = 
    N'Alter Table #TempOne Add [' + Cast(12.500000 As nVarChar) + N'% TAX VAT] Decimal(18, 6) 
    Default(0) Not Null'
  Exec sp_executesql @TempSql
End

Set @TempSql = 
  N'Alter Table #TempOne Add [Tax Total] Decimal(18, 6) 
  Default(0) Not Null'
  Exec sp_executesql @TempSql

Set @TempSql = 
  N'Update #TempOne Set [Tax Total] = [' + Cast(4.000000 As nVarChar) + N'% TAX VAT] + 
  [' + Cast(12.500000 As nVarChar) + N'% TAX VAT]'
  Exec sp_executesql @TempSql

Set @TempSql = 
  N'Alter Table #TempOne Add [Total  Amount] Decimal(18, 6) 
  Default(0) Not Null'
  Exec sp_executesql @TempSql

Set @TempSql = 
  N'Update #TempOne Set [Total  Amount] = [Total Amount] + [Tax Total]'
  Exec sp_executesql @TempSql

Select * From #TempOne

Drop Table #TempOne
Drop Table #TempTwo
Drop Table #TempThree
Drop Table #TempFour
Drop Table #TempFive





