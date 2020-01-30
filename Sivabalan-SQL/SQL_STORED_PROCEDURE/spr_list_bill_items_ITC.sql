Create PROCEDURE spr_list_bill_items_ITC(
@ID nVarchar(50),
@FromDate DateTime,
@ToDate DateTime,
@BreakUpValue nVarchar(20),
@UOM nVarchar(30))
AS
Begin
If @BreakUpValue = 'Yes'
Begin
Declare @BILLID int
Declare @Tax Int
Declare @Delimiter char(1)
--GST_Changes starts here
Declare @GSTaxCode int
Declare @GSTaxCompdesc nvarchar (50)
Declare @SQL nvarchar(4000)
Declare @GSTRate decimal(18,6)
Declare @GSTVal decimal(18,6)

Create Table #TempGSTaxCalc  --for gs tax calculation
(Id int identity(1,1),
BillID int,
ItemCode nvarchar(100),
TaxComponentCode int,
TaxComponentDesc  nvarchar(510),
TaxRate  decimal(18,6),
TaxValue decimal(18,6)
)
--GST_Changes ends here
Set @Delimiter = char(15)

Set @BillID = Cast(Left(@ID,CharIndex(@Delimiter,@ID)-1) as Int)
Set @Tax = Cast(Right(@ID,Len(@ID)-CharIndex(@Delimiter,@ID)) AS Int)
print  @BillID

SELECT BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code,
"Item Name" = Items.ProductName, "Batch" = BillDetail.Batch,
"Expiry" = BillDetail.Expiry,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Quantity" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.Quantity
WHEN 'UOM 1' THEN Cast(BillDetail.Quantity / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.Quantity / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,

"PFM" = CASE @UOM	WHEN 'Base UOM' THEN isnull(BillDetail.PFM, 0)
WHEN 'UOM 1' THEN Cast(isnull(BillDetail.PFM, 0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(isnull(BillDetail.PFM, 0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Net PTS" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.PurchasePrice
WHEN 'UOM 1' THEN Cast(BillDetail.PurchasePrice * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.PurchasePrice * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Original PTS" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.OrgPTS
WHEN 'UOM 1' THEN Cast(BillDetail.OrgPTS * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.OrgPTS * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"PTR" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.PTR
WHEN 'UOM 1' THEN Cast(BillDetail.PTR * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.PTR * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"MRP Per Pack" = isnull(BillDetail.MRPPerPack,0),
--CASE @UOM	WHEN 'Base UOM' THEN isnull(BillDetail.MRPPerPack,0)
--							WHEN 'UOM 1' THEN Cast(isnull(BillDetail.MRPPerPack,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
--							ELSE Cast(isnull(BillDetail.MRPPerPack,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
--							END,
"Goods Value" = BillDetail.Quantity * BillDetail.OrgPTS,
"Gross Amount" = BillDetail.Amount,
"Total Discount%" = IsNull((Select (Case When IsNull(DiscountOption,0) = 2
Then (BillDetail.Discount /IsNull((BillDetail.Quantity * BillDetail.PurchasePrice),1)*100)
Else BillDetail.Discount End) From BillAbstract Where BillID = BillDetail.BillID),0),

--"Total Discount/Unit" =  (IsNull(BillDetail.DiscPerUnit,0) /
--IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
-- When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1)) ,
"Total Discount/Unit" =  CASE @UOM
WHEN 'Base UOM' THEN (IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1))
WHEN 'UOM 1' THEN Cast((IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1)) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast((IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1)) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Inv Disc%" = IsNull(InvDiscPerc,0),
"Inv Disc% Amt" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (InvDiscPerc / 100),
"Inv Disc/Unit" =
--IsNull(InvDiscAmtPerUnit,0),
CASE @UOM	WHEN 'Base UOM' THEN IsNull(InvDiscAmtPerUnit,0)
WHEN 'UOM 1' THEN Cast(IsNull(InvDiscAmtPerUnit,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(InvDiscAmtPerUnit,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Inv Disc/Unit Amt" = Cast((IsNull(UOMQty,0) * IsNull(InvDiscAmtPerUnit,0)) as Decimal(18,6)),
"Inv Disc Total" =  Cast((Quantity * OrgPTS) as Decimal(18,6)) * (InvDiscPerc / 100) + Cast((IsNull(UOMQty,0) * IsNull(InvDiscAmtPerUnit,0)) as Decimal(18,6)),
"Othr Disc%" = IsNull(OtherDiscPerc,0),
"Othr Disc% Amt" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (OtherDiscPerc / 100),
"Othr Disc/Unit" =
--IsNull(OtherDiscAmtPerUnit,0),
CASE @UOM	WHEN 'Base UOM' THEN IsNull(OtherDiscAmtPerUnit,0)
WHEN 'UOM 1' THEN Cast(IsNull(OtherDiscAmtPerUnit,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(OtherDiscAmtPerUnit,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Othr Disc/Unit Amt" = Cast((IsNull(UOMQty,0) * IsNull(OtherDiscAmtPerUnit,0)) as Decimal(18,6)),
"Othr Disc Total" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (OtherDiscPerc / 100) + Cast((IsNull(UOMQty,0) * IsNull(OtherDiscAmtPerUnit,0)) as Decimal(18,6)),
"Product Discount Amount" = IsNull(( IsNull((Select (Case When IsNull(DiscountOption,0) = 2 Then BillDetail.Discount Else (IsNull(((Quantity * OrgPTS)* BillDetail.Discount / 100),0)) End) From BillAbstract Where BillID = BillDetail.BillID),0)  + IsNull((UOMQty * IsNull(DiscPerUnit,0)),0)),0),
"Surcharge" = BillDetail.Surcharge,
"Exempt" = Case When BillDetail.TaxCode = 0 Then BillDetail.Amount Else 0 End, --(Select Case When TaxAmount = 0 Then Amount Else 0 End From BillDetail BD Where BD.BillID = @BillID And TaxCode = 0 ),
"Tax Suffered" = BillDetail.TaxSuffered,
"TaxCode" = BillDetail.TaxCode,
"Tax Amount" = BillDetail.TaxAmount,
"Total" = BillDetail.Amount + BillDetail.TaxAmount,
"Serial" = BillDetail.Serial,
"HSNCode" = BillDetail.HSNNumber--GST_Changes
Into #TempBillDetails
FROM BillDetail
Left Outer Join Items On BillDetail.Product_Code = Items.Product_Code
Left Outer Join Tax  On BillDetail.TaxCode = Tax.Tax_Code
WHERE   BillDetail.BillID = @BILLID
And BillDetail.TaxCode = @Tax

Declare @ProductCode nVarchar(255)
Declare @TaxCode Int
Declare @i Int
Declare @LSTCompCount Int
Declare @CSTCompCount Int
Declare @ColumnName nVarchar(4000)
Declare @Str nVarchar(4000)
Declare @LSTCount Int
Declare @Count Int
Declare @Flag Int
Declare @LSTFlag Int
Declare @TaxCompCode Int
Declare @TaxCompAmount Decimal(18,6)
Declare @TaxCompPercentage Decimal(18,6)
Declare @PrevComp Int
Declare @Serial Int
Declare @TaxPercentage Int
Declare @SPPercentage Decimal(18,6)
Declare @Amount  Decimal(18,6)

Select [Product_Code], [Item Code], [Item Name], Batch, Expiry, Quantity,  [Net PTS], [Original PTS], PTR, [MRP Per Pack], [Goods Value], [Gross Amount], [Total Discount%],  [Total Discount/Unit],
[Inv Disc%],[Inv Disc% Amt],[Inv Disc/Unit],[Inv Disc/Unit Amt],[Inv disc Total],[Othr Disc%],[Othr Disc% Amt],[Othr Disc/Unit],[Othr Disc/Unit Amt],[Othr Disc Total],
[Product Discount Amount ],Surcharge, Exempt, [Tax Suffered], [TaxCode], [Tax Amount], Serial ,HSNCode --GST_Changes
Into #BillDetails From #TempBillDetails

Set @ColumnName = '[Product_Code],[Item Code], [Item Name], Batch, Expiry, Quantity, [Net PTS], [Original PTS], PTR, [MRP Per Pack], [Goods Value], [Gross Amount],
[Total Discount%],  [Total Discount/Unit], [Inv Disc%],[Inv Disc% Amt],[Inv Disc/Unit],[Inv Disc/Unit Amt],[Inv Disc Total],[Othr Disc%],[Othr Disc% Amt],[Othr Disc/Unit],[Othr Disc/Unit Amt],[Othr Disc Total],
[Product Discount Amount ],Surcharge, Exempt, [Tax Suffered], [Tax Amount],HSNCode' --GST_Changes

--Bill without GST starts here
Select Distinct #TempBillDetails.Product_Code, BillDetail.TaxCode, TaxComponents.TaxComponent_Code, LST_Flag,
(Select Count(TaxComponent_Code) From TaxComponents Where Tax_Code = BillDetail.TaxCode And Case When Vendors.Locality = 1 Then 1
Else 0 end = LST_Flag) as TaxCompLevel, BillDetail.Serial
Into #TempTaxDetails
From  BillAbstract, BillDetail, #TempBillDetails, Tax, TaxComponents,  Vendors
Where BillAbstract.BillID= BillDetail.BillID
And BillDetail.BillID = @BillID
And BillDetail.Product_Code = #TempBillDetails.Product_Code
And BillDetail.TaxCode = Tax.Tax_Code
And BillDetail.TaxCode = TaxComponents.Tax_Code
And Taxcomponents.Tax_Code = Tax.Tax_Code
And #TempBillDetails.TaxCode = @Tax
And BillAbstract.VendorID = Vendors.VendorID
And Case When Vendors.Locality = 1 Then 1
Else 0 end = LST_Flag
And BillAbstract.GSTFlag = 0 --GST_Changes
Group By #TempBillDetails.Product_Code, Vendors.Locality, BillDetail.TaxCode, TaxComponents.TaxComponent_Code, LST_Flag, BillDetail.Amount,
BillDetail.Serial

Select @LSTCount = IsNull(Max(TaxCompLevel),0) From #TempTaxDetails Where LST_Flag = 1
Select  @Count = IsNull(Max(TaxCompLevel),0) From #TempTaxDetails Where LST_Flag = 0
Set @Count = @LSTCount + @Count

Set @i = 1
Set @Str = ''
Set @LSTCompCount =1
Set @CSTCompCount = 1

While @i <=  @Count
Begin
If @i < = @LSTCount
Begin

Set @Str = 'Alter Table #BillDetails Add [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax%] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax%]'

Set @Str = 'Alter Table #BillDetails Add [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax Value] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax Value]'

Set @LSTCompCount = @LSTCompCount +1
End
Else
Begin
Set @Str = 'Alter Table #BillDetails Add [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax%] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax%]'

Set @Str = 'Alter Table #BillDetails Add [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax Value] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax Value]'

Set @CSTCompCount = @CSTCompCount +1
End
Set @i = @i + 1
End
--Bill without GST ends here
--Bill with GST,GST_Changes starts here
insert into #TempGSTaxCalc
(BillID , ItemCode  , TaxComponentCode , TaxComponentDesc , TaxRate , TaxValue)
select
GST.BillID , GST.Product_Code , GST.Tax_Component_Code , Tx.TaxComponent_Desc, Sum(Tax_Percentage) , Sum(Tax_Value)
from BillDetail  dt
join GSTBillTaxComponents	GST
on	 GST.BillID			=	dt.BillID
and	 GST.Product_Code	=	dt.Product_Code
and	 GST.Tax_Code		=	dt.TaxCode
join TaxComponentDetail	Tx
on	GST.Tax_Component_Code = Tx.TaxComponent_code
where GST.BillID = @BillID
And GST.Tax_Code = @Tax
group by GST.BillID , GST.Product_Code , GST.Tax_Component_Code , Tx.TaxComponent_Desc

--Update GST Columns
Declare GSTaxCompDesc  cursor for
select distinct  TaxComponentDesc  From #TempGSTaxCalc
Open GSTaxCompDesc
Fetch next from GSTaxCompDesc  into @GSTaxCompDesc
While(@@FETCH_STATUS =0)
Begin
Set @SQL = N'Alter Table #BillDetails Add ['+@GSTaxCompDesc+ N' Tax Rate] decimal(18,6) default 0;'
Set @ColumnName = @ColumnName + N', [' + @GSTaxCompDesc + N' Tax Rate]'
Exec(@SQL)

Set @SQL =  N'Alter Table #BillDetails Add [' +@GSTaxCompDesc + N' Tax Amount] decimal(18,6) default 0;'
Set @ColumnName = @ColumnName + N', [' + @GSTaxCompDesc + N' Tax Amount]'
Exec(@SQL)
Fetch next from GSTaxCompDesc  into @GSTaxCompDesc
End
Close GSTaxCompDesc
Deallocate GSTaxCompDesc

--Update GST Rate and Value
Declare GSTaxCompVal  cursor for
select distinct  ItemCode  , TaxComponentCode ,TaxComponentDesc, TaxRate , TaxValue  From #TempGSTaxCalc
Open GSTaxCompVal
Fetch next from GSTaxCompVal  into @ProductCode,@GSTaxCode ,@GSTaxCompDesc,@GSTRate, @GSTVal
While(@@FETCH_STATUS =0)
Begin
Select @SQL = 'Update #BillDetails Set ['+@GSTaxCompDesc+ N' Tax Rate] = ' + Cast(@GSTRate as nVarchar) +
' Where #BillDetails.[Item Code] = ' +'''' + Cast(@ProductCode as nvarchar) + ''''
Exec sp_executesql @SQL
Select @SQL = 'Update #BillDetails Set [' +@GSTaxCompDesc + N' Tax Amount] = ' + Cast(@GSTVal as nVarchar) +
' Where #BillDetails.[Item Code] = ' +'''' + Cast(@ProductCode as nvarchar) + ''''
Exec sp_executesql @SQL
Fetch next from GSTaxCompVal  into @ProductCode,@GSTaxCode ,@GSTaxCompDesc,@GSTRate, @GSTVal
End
Close GSTaxCompVal
Deallocate GSTaxCompVal
--Bill with GST,GST_Changes ends here

Alter Table #BillDetails Add Total Decimal(18,6)

Set @ColumnName = @ColumnName + ', Total'

Declare TaxCursor Cursor
For Select Distinct Product_Code, TaxCode, LST_Flag From  #TempTaxDetails
Order By  Product_Code, TaxCode
Open TaxCursor
Fetch Next From TaxCursor Into @ProductCode, @TaxCode, @LSTFlag
While @@Fetch_Status = 0
Begin
Set @i = 1
Select [ID] = Identity(Int,1,1), TaxComponents.TaxComponent_Code, Tax_Percentage, SP_Percentage, LST_Flag Into #Temp
From  TaxComponents
Where TaxComponents.Tax_Code = @Tax
And TaxComponents.LST_Flag = @LSTFlag
Order By SP_Percentage desc

Select @Count = Count(*) From #Temp

While @i < = @count
Begin
Select @TaxCompPercentage = Tax_Percentage, @SPPercentage = SP_Percentage From #Temp  Where [ID] = @i

If  @LSTFlag = 1
Begin
Set @Str =  'Update #BillDetails Set [LST Component ' + Cast(@i as nVarchar) + ' Tax%] = ' + Cast(@TaxCompPercentage as nVarchar) +
' Where #BillDetails.[Item Code] = ' +'''' + Cast(@ProductCode as nvarchar) + '''' +  ' And #BillDetails.TaxCode = ' + Cast(@TaxCode as nvarchar)

Exec sp_executesql @Str
Set @Str = 'Update #BillDetails Set [LST Component ' + Cast(@i as nVarchar) + ' Tax Value] = [Tax Amount]* ' + Cast(@SPPercentage as nVarchar) + ' / [Tax Suffered] ' +
' Where #BillDetails.[Item Code] = ''' + Cast(@ProductCode as nvarchar) +  ''' And #BillDetails.TaxCode = ' + Cast(@TaxCode as nvarchar)
Exec sp_executesql @Str
End
Else
Begin
Set @Str =  'Update #BillDetails Set [CST Component ' + Cast(@i as nVarchar) + ' Tax%] = ' + Cast(@TaxCompPercentage as nVarchar) +
' Where #BillDetails.[Item Code] = ' +'''' + Cast(@ProductCode as nvarchar) + '''' +  ' And #BillDetails.TaxCode = ' + Cast(@TaxCode as nvarchar)

Exec sp_executesql @Str
Set @Str = 'Update #BillDetails Set [CST Component ' + Cast(@i as nVarchar) + ' Tax Value] = [Tax Amount]* ' + Cast(@SPPercentage as nVarchar) + ' / [Tax Suffered] ' +
' Where #BillDetails.[Item Code] = ''' + Cast(@ProductCode as nvarchar) +  ''' And #BillDetails.TaxCode = ' + Cast(@TaxCode as nvarchar)
Exec sp_executesql @Str
End
Set @i = @i +1
End

Drop Table #Temp
Fetch Next From TaxCursor Into @ProductCode, @TaxCode, @LSTFlag
End
Close TaxCursor
Deallocate TaxCursor

Set @Str = 'Update #BillDetails Set Total = #BillDetails.[Gross Amount] + #BillDetails.[Tax Amount] From #TempBillDetails Where #BillDetails.[Item Code] = #TempBillDetails.Product_Code
And #BillDetails.TaxCode = #TempBillDetails.TaxCode'
Exec sp_executesql @Str

Set @Str = 'Select ' + @ColumnName + ' From #BillDetails'
Exec sp_executesql @Str

Drop Table #BillDetails
Drop Table #TempTaxDetails
Drop Table #TempBillDetails
Drop Table #TempGSTaxCalc--GST_Changes
End
Else
Begin

SELECT BillDetail.Product_Code, "Item Code" = BillDetail.Product_Code,
"Item Name" = Items.ProductName, "Batch" = BillDetail.Batch,
"Expiry" = BillDetail.Expiry,
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =Items.UOM2)
END,
"Quantity" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.Quantity
WHEN 'UOM 1' THEN Cast(BillDetail.Quantity / (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.Quantity / (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"PFM" = CASE @UOM	WHEN 'Base UOM' THEN isnull(BillDetail.PFM, 0)
WHEN 'UOM 1' THEN Cast(isnull(BillDetail.PFM, 0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(isnull(BillDetail.PFM, 0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Net PTS" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.PurchasePrice
WHEN 'UOM 1' THEN Cast(BillDetail.PurchasePrice * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.PurchasePrice * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Original PTS" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.OrgPTS
WHEN 'UOM 1' THEN Cast(BillDetail.OrgPTS * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.OrgPTS * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"PTR" = CASE @UOM	WHEN 'Base UOM' THEN BillDetail.PTR
WHEN 'UOM 1' THEN Cast(BillDetail.PTR * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(BillDetail.PTR * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"MRP Per Pack" = isnull(BillDetail.MRPPerPack,0),
--CASE @UOM	WHEN 'Base UOM' THEN isnull(BillDetail.MRPPerPack,0)
--							WHEN 'UOM 1' THEN Cast(isnull(BillDetail.MRPPerPack,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
--							ELSE Cast(isnull(BillDetail.MRPPerPack,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
--							END,
"Goods Value" = BillDetail.Quantity * BillDetail.OrgPTS,
"Gross Amount" = BillDetail.Amount,
"Total Discount%" = IsNull((Select (Case When IsNull(DiscountOption,0) = 2
Then (BillDetail.Discount /IsNull((BillDetail.Quantity * BillDetail.PurchasePrice),1)*100)
Else BillDetail.Discount End) From BillAbstract Where BillID = BillDetail.BillID),0),
--"Total Discount/Unit" =  IsNull(BillDetail.DiscPerUnit,0) /
--					   IsNull((Case When BillDetail.UOM = Items.UOM1 Then
--					   (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
--						When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0
--						Then 1 Else Items.UOM2_Conversion End) Else 1 End),1) ,
"Total Discount/Unit" =  CASE @UOM
WHEN 'Base UOM' THEN (IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1))
WHEN 'UOM 1' THEN Cast((IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1)) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast((IsNull(BillDetail.DiscPerUnit,0) /
IsNull((Case When BillDetail.UOM = Items.UOM1 Then (Case when IsNull(Items.UOM1_Conversion,0) = 0 Then 1 Else Items.UOM1_Conversion End)
When BillDetail.UOM = Items.UOM2 Then (Case when IsNull(Items.UOM2_Conversion,0) = 0 Then 1 Else Items.UOM2_Conversion End) Else 1 End),1)) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Inv Disc%" = IsNull(InvDiscPerc,0),
"Inv Disc% Amt" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (InvDiscPerc / 100),
"Inv Disc/Unit" =
--IsNull(InvDiscAmtPerUnit,0),
CASE @UOM	WHEN 'Base UOM' THEN IsNull(InvDiscAmtPerUnit,0)
WHEN 'UOM 1' THEN Cast(IsNull(InvDiscAmtPerUnit,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(InvDiscAmtPerUnit,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Inv Disc/Unit Amt" = Cast((IsNull(UOMQty,0) * IsNull(InvDiscAmtPerUnit,0)) as Decimal(18,6)),
"Inv Disc Total" =  Cast((Quantity * OrgPTS) as Decimal(18,6)) * (InvDiscPerc / 100) + Cast((IsNull(UOMQty,0) * IsNull(InvDiscAmtPerUnit,0)) as Decimal(18,6)),
"Othr Disc%" = IsNull(OtherDiscPerc,0),
"Othr Disc% Amt" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (OtherDiscPerc / 100),
"Othr Disc/Unit" =
--IsNull(OtherDiscAmtPerUnit,0),
CASE @UOM	WHEN 'Base UOM' THEN IsNull(OtherDiscAmtPerUnit,0)
WHEN 'UOM 1' THEN Cast(IsNull(OtherDiscAmtPerUnit,0) * (Case IsNull(Items.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(IsNull(OtherDiscAmtPerUnit,0) * (Case IsNull(Items.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(Items.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Othr Disc/Unit Amt" = Cast((IsNull(UOMQty,0) * IsNull(OtherDiscAmtPerUnit,0)) as Decimal(18,6)),
"Othr Disc Total" = Cast((Quantity * OrgPTS) as Decimal(18,6)) * (OtherDiscPerc / 100) + Cast((IsNull(UOMQty,0) * IsNull(OtherDiscAmtPerUnit,0)) as Decimal(18,6)),
"Product Discount Amount" = IsNull(( IsNull((Select (Case When IsNull(DiscountOption,0) = 2 Then BillDetail.Discount Else (IsNull(((Quantity * OrgPTS)* BillDetail.Discount / 100),0)) End) From BillAbstract Where BillID = BillDetail.BillID),0)  + IsNull((UOMQty * IsNull(DiscPerUnit,0)),0)),0),
"Surcharge" = BillDetail.Surcharge,
--	 "Exempt" = Case When BillDetail.TaxCode = 0 Then BillDetail.Amount Else 0 End, --(Select Case When TaxAmount = 0 Then Amount Else 0 End From BillDetail BD Where BD.BillID = @BillID And TaxCode = 0 ),
"Tax Suffered" = BillDetail.TaxSuffered,
"Tax Amount" = BillDetail.TaxAmount,
"Total" = BillDetail.Amount + BillDetail.TaxAmount,
"HSNCode" = BillDetail.HSNNumber --GST_Changes
FROM BillDetail
Left Outer Join Items On BillDetail.Product_Code = Items.Product_Code
WHERE   BillDetail.BillID = @ID
--Select [Item Code], [Item Name], Expiry, Rate, MRP, [Goods Value], [Gross Amount], Discount, Surcharge, [Tax Suffered], [Tax Amount], Total From #TempBillDetails
--  Select Product_Code, [Item Code], [Item Name], Batch, Expiry, Quantity, Rate, PTR, MRP, [Goods Value], [Gross Amount], Discount, Surcharge, [Tax Suffered], [Tax Amount], Total From #TempBillDetails
End
End
