Create PROCEDURE spr_list_bills_ITC(
@VENDOR nvarchar(2550),
@Tax nVarchar(4000),
@FROMDATE datetime,
@TODATE datetime,
@BreakUpValue nVarchar(20),
@Uom nVarchar(30)
)
AS


--Set @VENDOR = '%'
--Set @Tax  = '%'
--Set @FROMDATE = '2017-05-01 00:00:00'
--Set @TODATE  ='2017-05-19 23:59:59'
--Set @BreakUpValue = 'Yes'

Declare @Delimeter as Char(1)
Declare @OPEN As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @CLOSED As NVarchar(50)
Declare @CS_TaxCode int
Declare @TaxComp_Code int
Declare @TaxComp_desc nvarchar (50)
Declare @GSTIN nvarchar(15)
Declare @FromStatecode int
Declare @ToStatecode int
--declare @TaxAmount int

Set @Delimeter=Char(15)
Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default)

Create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TempTax (TaxID Int)

if @VENDOR=N'%'
insert into #tmpVen select Vendor_Name from Vendors
else
insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)


If @Tax = N'%'
Insert Into #TempTax Select Tax_Code From Tax
Else
Insert Into #TempTax Select Tax_Code From Tax Where Tax_Description In(Select * From dbo.sp_SplitIn2Rows(@Tax, @Delimeter))

SELECT  BillAbstract.BillID, "Bill ID" = CASE
WHEN DocumentReference IS NULL THEN
BillPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
ELSE
BillAPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
END,
"Bill Date" = BillDate,
"CreditTerm"  = CreditTerm.Description,
"Payment Date" = PaymentDate, "InvoiceReference" = InvoiceReference,
"Vendor" = Vendors.Vendor_Name,
--"Gross Amount" = (Select Sum(Quantity * PurchasePrice) From BillDetail
"Gross Amount" = (Select Sum(Quantity * OrgPTS) From BillDetail
Where BillDetail.BillID = BillAbstract.BillID),
"Exempt" = (Select Case When BD.Taxcode = 0 Then Sum(BD.Amount) Else 0 End
From BillDetail BD
Where BD.BillID = BillAbstract.BillID
And BD.TaxCode = TaxCode
And BD.TaxCode = 0
Group By BD.Taxcode),
"Tax%" = Tax.Percentage,
"TaxCode" = BillDetail.TaxCode,
"Tax Amount" = Sum(BillDetail.TaxAmount),
"Trade Discount%" = Max(BillAbstract.Discount),
"Trade Discount Amount" = Cast((Case When IsNull(DiscountOption,0) = 2 Then
(Select Sum( (Quantity * OrgPTS)-(Discount) - (IsNull(UOMQty,0) * IsNull(DiscPerUnit,0)))  From BillDetail
Where BillDetail.BillID = BillAbstract.BillID)
Else
(Select Sum( (Quantity * OrgPTS)-((Quantity * OrgPTS)* Discount /100) - (IsNull(UOMQty,0) * IsNull(DiscPerUnit,0)))  From BillDetail
Where BillDetail.BillID = BillAbstract.BillID) End) * BillAbstract.Discount / 100 as Decimal(18,6)),
"Inv Disc% Total" = (Select Case Sum(IsNull(InvDiscPerc,0)) When 0 Then 0 Else Cast(Sum(Cast((Quantity * OrgPTS) as Decimal(18,6)) * (InvDiscPerc/100)) as Decimal(18,6)) End  From BillDetail Where BillDetail.BillID = BillAbstract.BillID),
"Inv Disc/Unit Total" = (Select Sum(Cast((IsNull(UOMQty,0) * IsNull(InvDiscAmtPerUnit,0)) as Decimal(18,6)))  From BillDetail Where BillDetail.BillID = BillAbstract.BillID),
"Othr Disc% Total" = (Select Case Sum(IsNull(OtherDiscPerc,0)) When 0 then 0 Else Cast(Sum(Cast((Quantity * OrgPTS) as Decimal(18,6)) * (OtherDiscPerc/100)) as Decimal(18,6)) End From BillDetail Where BillDetail.BillID = BillAbstract.BillID),
"Othr Disc/Unit Total" = (Select Sum(Cast((IsNull(UOMQty,0) * IsNull(OtherDiscAmtPerUnit,0)) as Decimal(18,6)))  From BillDetail Where BillDetail.BillID = BillAbstract.BillID),
"Product Discount Amount" = Case When IsNull(DiscountOption,0) = 2 Then (Select Sum(Discount + (IsNull(UOMQty,0) * IsNull(DiscPerUnit,0)))  From BillDetail
Where BillDetail.BillID = BillAbstract.BillID) Else (Select Sum(((Quantity * OrgPTS)* Discount /100) + (IsNull(UOMQty,0) * IsNull(DiscPerUnit,0)))  From BillDetail
Where BillDetail.BillID = BillAbstract.BillID) End ,
"Adjustment Amount" = AdjustmentAmount,
"Adjusted Amount" = AdjustedAmount,
"Net Amount" = Billabstract.Value + BillAbstract.TaxAmount + AdjustmentAmount,
"GRNID" = GRNPrefix.Prefix + CAST(NewGRNID AS nVARCHAR),
--"GSTIN" = MAX(BillAbstract.GSTIN),
--"FromStatecode" =BillAbstract.FromStatecode,
--"ToStatecode"=BillAbstract.ToStatecode,

"GRN DATE" = dbo.fn_Get_GRN_DateSerial(BillAbstract.BillID),
-- No longer req > 1 checking.
"Status" = (Case When (( IsNull(BillAbstract.Value,0) + IsNull(BillAbstract.AdjustmentAmount,0) + IsNull(BillAbstract.TaxAmount,0) - IsNull(BillAbstract.AdjustedAmount,0) )- IsNull(Balance,0)) > 1 Then @CLOSED Else @OPEN End),
--	CASE Status
--	WHEN 0 THEN @OPEN
--	WHEN 128 THEN @AMENDED
--	ELSE @CANCELLED
--	END,
"Original Bill" = CASE DocumentReference
WHEN NULL THEN N''
ELSE BillPrefix.Prefix + CAST(DocumentReference AS nVARCHAR)
END,
"Branch" = ClientInformation.Description, "ST"  = TNGST, CST,
"Tax Type" = Case When IsNull(BillAbstract.StateType , 0) > 0 Then
(Case IsNull(BillAbstract.StateType, 0)
When 1 Then 'Intra'
When 2 Then 'Inter' End)
Else
(Case IsNull(BillAbstract.TaxType, 0)
When 1 Then 'LST'
When 2 Then 'CST'
When 3 Then 'FLST' End)  End,
"GSTINOfVendor" = MAX(BillAbstract.GSTIN),
"FromStatecode" = (Select Max(ForumStateCode) From  StateCode Where StateID = BillAbstract.FromStatecode),
"ToStatecode"= (Select Max(ForumStateCode) From  StateCode Where StateID = BillAbstract.ToStatecode),
"ODNumber"= BillAbstract.ODNumber
Into #TempBillDetails
FROM BillAbstract
Inner Join BillDetail On BillAbstract.BillID = BillDetail.BillID
Inner Join Vendors On BillAbstract.VendorID = Vendors.VendorID
Inner Join VoucherPrefix BillPrefix On BillPrefix.TranID = N'BILL'
Inner Join VoucherPrefix GRNPrefix On GRNPrefix.TranID = N'GOODS RECEIVED NOTE'
Left Outer Join ClientInformation On BillAbstract.ClientID = ClientInformation.ClientID
Inner Join VoucherPrefix BillAPrefix On BillAPrefix.TranID = N'BILL AMENDMENT'
Left Outer Join CreditTerm On 	CreditTerm.CreditID = BillAbstract.CreditTerm
Left Outer Join Tax On BillDetail.TaxCode = Tax.Tax_Code
WHERE   BillDate BETWEEN @FROMDATE AND @TODATE AND
Vendors.Vendor_Name in(select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) AND
IsNull(BillAbstract.Status, 0) & 192 = 0
And Tax.Tax_Code In(Select TaxID From #TempTax)
Group By BillAbstract.BillID,  BillDate, BillAbstract.CreditTerm, PaymentDate, InvoiceReference , ClientInformation.Description,TNGST, CST,
BillPrefix.Prefix, BillAbstract.DocumentID	, Vendors.Vendor_Name, BillAbstract.Discount, BillAbstract.DocumentReference, BillAPrefix.Prefix,
CreditTerm.Description, GRNPrefix.Prefix, BillAbstract.NewGRNID, BillAbstract.Status, Tax.Percentage, BillDetail.TaxCode,
Billabstract.Value, BillAbstract.TaxAmount, AdjustmentAmount, AdjustedAmount,Billabstract.Balance, Billabstract.DiscountOption,
BillAbstract.TaxType,BillAbstract.StateType , BillAbstract.GSTIN,BillAbstract.FromStatecode,BillAbstract.ToStatecode,BillAbstract.ODNumber
ORDER BY BillAbstract.BillDate


If @BreakUpValue = 'Yes'
Begin
Declare @Count as Int
Declare @LSTCount as Int
Declare @CSTCount as Int
Declare @i Int
Declare @Str as nVarchar(4000)
Declare @BillID Int
Declare @TaxID Int
Declare @SQL nvarchar(4000)
Declare @TaxCompCode Int, @SP_Percentage Decimal(18,6)
Declare @TaxCompAmount Decimal(18,6)
Declare @Flag Int
Declare @TaxCompPercentage Decimal(18,6)
Declare @LSTFlag Int
Declare @TempColumn as nVarchar(4000)
Declare @LSTCompCount Int
Declare @CSTCompCount Int
Declare @ColumnName nVarchar(4000)

--Insert Values for Static Columns
Select BillID, [Bill ID], [Bill Date], CreditTerm, [Payment Date], InvoiceReference ,Vendor, [Gross Amount], Exempt,[Tax%],[TaxCode],[Tax Amount],GSTINOfVendor,FromStateCode,ToStateCode,ODNumber
Into #BillDetails From #TempBillDetails

--Get Max number of Tax Component Levels
Select Distinct #TempBillDetails.BillID, BillDetail.TaxCode, TaxComponents.TaxComponent_Code, LST_Flag,--, BillDetail.Amount, (BillDetail.Amount * (SP_Percentage /100)) as TaxCompValue,
(Select Count(TaxComponent_Code) From TaxComponents Where Tax_Code = BillDetail.TaxCode And Case When Vendors.Locality = 1 Then 1
Else 0 end	= LST_Flag) as TaxCompLevel ,"TaxCompDesc"= TaxComponentDetail.TaxComponent_desc ,"CS_TaxCode"=Tax.CS_TaxCode
Into #TempTaxDetails
From #TempBillDetails, BillAbstract, BillDetail, Tax, TaxComponents, TaxComponentDetail, Vendors
Where BillAbstract.BillID = #TempBillDetails.BillID
And #TempBillDetails.BillID = BillDetail.BillID
And BillAbstract.BillDate Between @FROMDATE And @TODATE
And BillDetail.TaxCode = Tax.Tax_Code
And Tax.Tax_Code = TaxComponents.Tax_Code
And BillAbstract.VendorID = Vendors.VendorID
And TaxComponents.TaxComponent_Code = TaxComponentDetail.TaxComponent_Code
And Case When Vendors.Locality = 1 Then 1
Else 0 end	= LST_Flag
Select @LSTCount = IsNull(Max(TaxCompLevel),0) From #TempTaxDetails Where LST_Flag = 1	 and CS_TaxCode = 0
Select @Count = IsNull(Max(TaxCompLevel),0) From #TempTaxDetails	Where LST_Flag = 0	 and CS_TaxCode = 0

Set @Count = @LSTCount + @Count

Set @i = 1
Set @LSTCompCount =1
Set @CSTCompCount =1
Set @ColumnName = 'Cast(BillID as varchar) + char(15) + Cast(TaxCode as varchar) as BillID , [Bill ID], [Bill Date], CreditTerm, [Payment Date], InvoiceReference ,Vendor, [Gross Amount],Exempt, [Tax%] ,[Tax Amount] '--, GSTIN,FromStatecode,ToStatecode '
While @i <=  @Count
Begin
If @i < = @LSTCount
Begin
Set @Str = 'Alter Table #BillDetails Add [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax%] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax%]'

Set @Str = 'Alter Table #BillDetails Add [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax Amount] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax Amount]'

Set @LSTCompCount = @LSTCompCount +1
End
Else
Begin
Set @Str = 'Alter Table #BillDetails Add [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax%] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax%]'

Set @Str = 'Alter Table #BillDetails Add [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax Amount] Decimal(18,6)'
Exec sp_executesql @Str
Set @ColumnName = @ColumnName + ', [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax Amount]'

Set @CSTCompCount = @CSTCompCount +1
End
Set @i = @i + 1
End

Declare TaxCompDesc  cursor for
select distinct  TaxCompDesc  From #TempTaxDetails where isnull(CS_TaxCode,0) = 0
--order by Tax_Component_Code, CompType Desc

Open TaxCompDesc
Fetch next from TaxCompDesc  into @TaxComp_desc
While(@@FETCH_STATUS =0)
begin

Begin
--Update Value
Set @SQL =  'Alter Table #BillDetails Add [' +Cast(@TaxComp_desc as varchar)+ N' Tax Amount] decimal(18,6) default 0;'
--Exec sp_executesql @SQL
Set @ColumnName = @ColumnName + N', [' + @TaxComp_desc + N' Tax Amount]'

Set @SQL = @SQL +'Alter Table #BillDetails Add ['+Cast(@TaxComp_desc as varchar)+ N' Tax Rate] decimal(18,6) default 0;'
Exec sp_executesql @SQL
Set @ColumnName = @ColumnName + N', [' + @TaxComp_desc + N' Tax Rate]'

--Print @SQL


End



Fetch next from TaxCompDesc  into @TaxComp_desc
End
Close TaxCompDesc
Deallocate TaxCompDesc

--select * from #TempTaxDetails
--Append Static columns
Alter Table #BillDetails Add 	[Trade Discount%] Decimal(18,6), [Trade Discount Amount] Decimal(18,6),
[Inv Disc% Total] Decimal(18,6), [Inv Disc/Unit Total] Decimal(18,6),  [Othr Disc% Total] Decimal(18,6), [Othr Disc/Unit Total] Decimal(18,6),
[Product Discount Amount] Decimal(18,6), [Adjustment Amount] Decimal(18,6), [Adjusted Amount] Decimal(18,6), [Net Amount] Decimal(18,6),
GRNID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, [GRN DATE] nVarchar(2000), Status nVarchar(20)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Original Bill] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Branch nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ST nVarchar(50)
COLLATE SQL_Latin1_General_CP1_CI_AS ,
CST nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, [Tax Type] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS

--Update Values for Static Columns
Set @TempColumn = 'Update #BillDetails Set  #BillDetails.[Trade Discount%] = T2.[Trade Discount%], #BillDetails.[Trade Discount Amount] = T2.[Trade Discount Amount],  ' +
'#BillDetails.[Inv Disc% Total] = T2.[Inv Disc% Total],  #BillDetails.[Inv Disc/Unit Total] = T2.[Inv Disc/Unit Total], ' +
'#BillDetails.[Othr Disc% Total] = T2.[Othr Disc% Total], #BillDetails.[Othr Disc/Unit Total] =T2.[Othr Disc/Unit Total], ' +
'#BillDetails.[Product Discount Amount] = T2.[Product Discount Amount],#BillDetails.[Adjustment Amount] = T2.[Adjustment Amount], #BillDetails.[Adjusted Amount] = T2.[Adjusted Amount], #BillDetails.[Net Amount] = T2.[Net Amount], #BillDetails.GRNID = T2.GRNID, #BillDetails.[GRN DATE] = T2.[GRN DATE],  ' +
'#BillDetails.Status = T2.Status, #BillDetails.[Original Bill] = T2.[Original Bill], #BillDetails.Branch = T2.Branch, #BillDetails.ST = T2.ST, #BillDetails.CST = T2.CST,  ' +
'#BillDetails.[Tax Type] = T2.[Tax Type] ' +
'From  #TempBillDetails T2 ' +
'Where #BillDetails.BillID =  T2.BillID And #BillDetails.TaxCode = T2.TaxCode '
Exec sp_executesql  @TempColumn

Set @ColumnName = @ColumnName + ', [Trade Discount%],[Trade Discount Amount], [Inv Disc% Total], [Inv Disc/Unit Total], [Othr Disc% Total], [Othr Disc/Unit Total]' +
' [Adjustment Amount],[Product Discount Amount], [Adjusted Amount], [Net Amount], [GRNID], [GRN DATE], [Status], [Original Bill], Branch, ST, CST, [Tax Type],GSTINOfVendor,FromStatecode,ToStatecode,ODNumber  '
--select * from #TempBillDetails
Declare BillCursor Cursor
For Select Distinct(BillID),TaxCode, LST_Flag From #TempTaxDetails  where CS_TaxCode = 0
Open BillCursor
Fetch Next From BillCursor Into @BillID, @TaxID, @LSTFlag
While @@Fetch_Status =0
Begin
Set @i = 1
Set @LSTCompCount =1
Set @CSTCompCount =1
Declare UpdateTaxComponent Cursor
For 	Select Distinct TaxComponents.TaxComponent_Code, LST_Flag, Max(Tax_Percentage),
(Case When LST_Flag = 1 Then Case When BillDetail.TOQ=1 Then Sum((BillDetail.TaxAmount*TaxComponents.SP_Percentage)/case when Tax.Percentage > 0 then Tax.Percentage else 1 end * case when Tax.Percentage = 0 then 0 end) Else Sum(BillDetail.Amount * ((LSTPartOff/100) * (SP_Percentage /100) )) End
Else Case When BillDetail.TOQ=1 Then Sum((BillDetail.TaxAmount*TaxComponents.SP_Percentage)/case when Tax.Percentage > 0 then Tax.Percentage else 1 end * case when Tax.Percentage = 0 then 0 end) Else Sum(BillDetail.Amount * ((CSTPartOff/100) * (SP_Percentage /100))) End End )
as TaxCompValue, TaxComponents.SP_Percentage,"CS_TaxCode"=Tax.CS_TaxCode,TaxComponentDetail.TaxComponent_desc
From #TempBillDetails, Tax, TaxComponents, BillDetail,TaxComponentDetail
Where #TempBillDetails.TaxCode = Tax.Tax_Code
And Tax.Tax_Code = TaxComponents.Tax_Code
And BillDetail.BillID = #TempBillDetails.BillID
And BillDetail.TaxCode = #TempBillDetails.TaxCode
And BillDetail.BillID = @BillID
And BillDetail.TaxCode = @TaxID
And TaxComponents.LST_Flag = @LSTFlag
Group By TaxComponents.TaxComponent_Code, LST_Flag, TaxComponents.SP_Percentage,BillDetail.TOQ,Tax.CS_TaxCode,TaxComponentDetail.TaxComponent_desc
Order By TaxComponents.SP_Percentage desc
Open UpdateTaxComponent
Fetch Next From UpdateTaxComponent Into @TaxCompCode, @Flag, @TaxCompPercentage, @TaxCompAmount, @SP_Percentage ,@TaxComp_Desc,@TaxComp_Code
While @@Fetch_Status = 0
Begin
If(@CS_TaxCode > 0)
begin
--	If @Flag = 1
--Begin
Set @Str = 'Update #BillDetails Set ['+@TaxComp_desc+ N' Tax Rate] = '	+	Cast(@TaxCompPercentage as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)

Exec sp_executesql @Str

Set @Str = 'Update #BillDetails Set [' +@TaxComp_desc + N' Tax Amount] = '	+	Cast(@TaxCompAmount as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)
Exec sp_executesql @Str
Set @LSTCompCount = @LSTCompCount +1
--End
--Else
--Begin
--	Set @Str = 'Update #BillDetails Set ['+@TaxComp_desc+ N' Tax Rate] = '	+	Cast(@TaxCompPercentage as Varchar) +
--			' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)

--	Exec sp_executesql @Str

--	Set @Str = 'Update #BillDetails Set [' +@TaxComp_desc + N' Tax Amount] = '	+	Cast(@TaxCompAmount as Varchar) +
--				' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)
--	Exec sp_executesql @Str
--	Set @CSTCompCount = @CSTCompCount +1
--End

--	Set @i = @i + 1
--Fetch Next From UpdateTaxComponent Into @TaxCompCode, @Flag, @TaxCompPercentage, @TaxCompAmount, @SP_Percentage ,@TaxComp_Desc,@TaxComp_Code
End
--end

else

begin
If @Flag = 1
Begin
Set @Str = 'Update #BillDetails Set [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax%] = '	+	Cast(@TaxCompPercentage as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)

Exec sp_executesql @Str

Set @Str = 'Update #BillDetails Set [LST Component ' + Cast(@LSTCompCount as Varchar) + ' Tax Amount] = '	+	Cast(@TaxCompAmount as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)
Exec sp_executesql @Str
Set @LSTCompCount = @LSTCompCount +1
End
Else
Begin
Set @Str = 'Update #BillDetails Set [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax%] = '	+	Cast(@TaxCompPercentage as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)

Exec sp_executesql @Str

Set @Str = 'Update #BillDetails Set [CST Component ' + Cast(@CSTCompCount as Varchar) + ' Tax Amount] = '	+	Cast(@TaxCompAmount as Varchar) +
' Where #BillDetails.BillID = ' + Cast(@BillID as varchar) + ' And #BillDetails.TaxCode = ' + Cast(@TaxID as varchar) + ' And ' + Cast(@LSTFlag as varchar) + ' = ' + Cast(@Flag as varchar)
Exec sp_executesql @Str
Set @CSTCompCount = @CSTCompCount +1
End
end
Set @i = @i + 1
Fetch Next From UpdateTaxComponent Into @TaxCompCode, @Flag, @TaxCompPercentage, @TaxCompAmount, @SP_Percentage  ,@TaxComp_Desc,@TaxComp_Code
End
Close UpdateTaxComponent
Deallocate UpdateTaxComponent
Fetch Next From BillCursor Into @BillID, @TaxID, @LSTFlag
End
Close BillCursor
Deallocate BillCursor

Update #BillDetails Set Exempt = 0 Where IsNull([Tax%],0) <> 0
--Update values to dynamic columns
Set @Str = 'Select ' + @ColumnName + ' From #BillDetails'
Exec sp_executesql @Str



Drop Table #BillDetails
Drop Table #TempTaxDetails
End

Else
Begin
Select Cast(BillID as varchar) , [Bill ID], [Bill Date], [CreditTerm], [Payment Date], InvoiceReference, [Vendor],
[Gross Amount], Sum([Tax Amount]) [Tax Amount], [Trade Discount%],[Trade Discount Amount],
[Inv Disc% Total], [Inv Disc/Unit Total], [Othr Disc% Total], [Othr Disc/Unit Total], [Product Discount Amount],
[Adjustment Amount], [Adjusted Amount], [Net Amount], [GRNID], [GRN DATE], [Status], [Original Bill], Branch,
ST, CST, [Tax Type] ,GSTINOfVendor,FromStatecode,ToStatecode, ODNumber
From #TempBillDetails
Group By BillID, [Bill ID], [Bill Date], [CreditTerm], [Payment Date], InvoiceReference, [Vendor],
[Gross Amount], [Trade Discount%],[Trade Discount Amount], [Inv Disc% Total], [Inv Disc/Unit Total], [Othr Disc% Total], [Othr Disc/Unit Total],
[Product Discount Amount], [Adjustment Amount], [Adjusted Amount], [Net Amount], [GRNID], [GRN DATE], [Status], [Original Bill], Branch, ST, CST, [Tax Type],
GSTINOfVendor,FromStatecode,ToStatecode,ODNumber

End

Drop Table #TempBillDetails
Drop table #tmpVen
Drop Table #TempTax

