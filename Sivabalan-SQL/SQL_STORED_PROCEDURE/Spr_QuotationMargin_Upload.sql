Create Procedure [dbo].Spr_QuotationMargin_Upload(@ProductHierarchy Nvarchar(255), @Category Nvarchar(4000),@ItemCode Nvarchar(4000),@UOM Nvarchar(4000),@FromDate DateTime,@ToDate DateTime)
As
Begin
Set DateFormat DMY
Declare @Delimeter as Char(1)
Declare @DetailInput as Nvarchar(4000)

Declare @DayClosed Int
Select @DayClosed = 0
IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
IF ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@TODATE))
Set @DayClosed = 1
End

IF @DayClosed = 0
GoTo OvernOut

Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

IF @CompaniesToUploadCode='ITC001'
Begin
Set @WDDest = @WDCode
End
Else
Begin
Set @WDDest = @WDCode
Set @WDCode = @CompaniesToUploadCode
End

Create Table #tempCategory (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null)
Create Table #tempItem (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS Null)
Declare @ForumCode as Nvarchar(255)
Declare @WDName as Nvarchar(500)
select @ForumCode = RegisteredOwner, @WDName = OrganisationTitle From SetUp

CREATE TABLE #TempAbs(
[Detail Info] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item Code] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Item Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UOM] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [decimal](18, 6) NULL,
[Sales Value] [decimal](18, 6) NULL,
[PTR Value] [decimal](18, 6) NULL,
[Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sub Category] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Market SKU] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Customer ID] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Quotation Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS
)

Create Table #tmpInvAbsDet(InvoiceID int, QuotationID int, CustomerID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18, 6), SalePrice Decimal(18, 6),
PTR Decimal(18, 6),	TaxCode Decimal(18, 6), TaxCode2 Decimal(18, 6), TOQ int, TaxID int, TaxType int, RegisterFlag int)

Create Table #tmpFinalInvAbsDet(InvoiceID int, QuotationID int, CustomerID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18, 6),
SaleValue Decimal(18, 6), PTRValue Decimal(18, 6))

Insert Into #tmpInvAbsDet(InvoiceID, QuotationID, CustomerID, Product_Code, Quantity, SalePrice, PTR, TaxCode, TaxCode2, TOQ, TaxID, TaxType, RegisterFlag)
Select IA.InvoiceID, ID.QuotationID, IA.CustomerID, ID.Product_Code, Sum(ID.Quantity), Max(ID.SalePrice), Max(ID.PTR),
Max(TaxCode), Max(TaxCode2)	, Max(isnull(ID.TaxonQty,0)), ID.TaxID, dbo.FN_Get_GST_CustomerLocality(IA.CustomerID) TaxType,
Case When isnull(IA.GSTIN,'') = '' Then 2 Else 1 End RegisterFlag
From InvoiceAbstract IA, InvoiceDetail ID
Where IA.InvoiceID = ID.InvoiceID and  (IA.Status & 128) = 0 and  IA.InvoiceType in (1,3)
and dbo.stripdatefromtime(IA.Invoicedate) Between @FromDate and @ToDate
and Isnull(ID.QuotationID,0) > 0
Group By IA.InvoiceID, ID.QuotationID, IA.CustomerID, ID.Product_Code, ID.Serial, ID.TaxID, IA.GSTIN

Insert Into #tmpFinalInvAbsDet(InvoiceID, QuotationID, CustomerID, Product_Code, Quantity, SaleValue, PTRValue)
Select InvoiceID, QuotationID, CustomerID, Product_Code, Sum(Quantity),

Case When isnull(T.CS_TaxCode,0) > 0 Then
(Sum(Tmp.Quantity * Tmp.SalePrice) + isnull(dbo.Fn_TaxCompCalc_CalamityCess(Tmp.Product_Code,Tmp.TaxID,Tmp.TaxType,Sum(Tmp.Quantity * Tmp.SalePrice),Sum(Tmp.Quantity),1,0,Tmp.RegisterFlag),0))
Else
Case When Max(Tmp.TOQ) = 1 Then
(Case When Max(Tmp.Taxcode2) > 0 Then Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.SalePrice)), 0) +  (Tmp.Quantity * Tmp.Taxcode2) )) as Decimal(18,6))
Else Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.SalePrice)), 0) +  (Tmp.Quantity * Tmp.Taxcode) )) as Decimal(18,6)) End)
Else
(Case When Max(Tmp.Taxcode2) > 0 Then Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.SalePrice)), 0) +  ((Tmp.Quantity * Tmp.SalePrice * Tmp.Taxcode2)/100) )) as Decimal(18,6))
Else Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.SalePrice)), 0) +  ((Tmp.Quantity * Tmp.SalePrice * Tmp.Taxcode)/100) )) as Decimal(18,6)) End)
End
End [SaleValue],

Case When isnull(T.CS_TaxCode,0) > 0 Then
(Sum(Tmp.Quantity * Tmp.PTR) + isnull(dbo.Fn_TaxCompCalc_CalamityCess(Tmp.Product_Code,Tmp.TaxID,Tmp.TaxType,Sum(Tmp.Quantity * Tmp.PTR),Sum(Tmp.Quantity),1,0,Tmp.RegisterFlag),0))
Else
Case When Max(Tmp.TOQ) = 1 Then
(Case When Max(Tmp.Taxcode2) > 0 Then Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.PTR)), 0) +  (Tmp.Quantity * Tmp.Taxcode2) )) as Decimal(18,6))
Else Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.PTR)), 0) +  (Tmp.Quantity * Tmp.Taxcode) )) as Decimal(18,6)) End)
Else
(Case When Max(Tmp.Taxcode2) > 0 Then Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.PTR)), 0) + ((Tmp.Quantity * Tmp.PTR * Tmp.Taxcode2)/100) )) as Decimal(18,6))
Else Cast((Sum(Isnull(((Tmp.Quantity) * (Tmp.PTR)), 0) + ((Tmp.Quantity * Tmp.PTR * Tmp.Taxcode)/100) )) as Decimal(18,6)) End)
End
End[PTRValue]

From #tmpInvAbsDet Tmp
Inner Join Tax T ON Tmp.TaxID = T.Tax_Code
Group By Tmp.InvoiceID, Tmp.QuotationID, Tmp.CustomerID, Tmp.Product_Code, Tmp.TaxID, T.CS_TaxCode, Tmp.TaxType, Tmp.RegisterFlag


Set @Delimeter=Char(15)

If @Category = '%'
Begin
Insert Into #tempCategory (Category) Select Distinct Category_Name From ItemCategories Where Level = 2
End
Else
Begin
Insert Into #tempCategory (Category)  select Category_Name From itemcategories Where Category_Name   In(Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))
End

If @ItemCode = '%'
Begin
Insert Into #tempItem (Product_Code) Select Distinct Product_Code From Items
End
Else
Begin
Insert Into #tempItem (Product_Code)  select Distinct Product_Code From Items Where Product_Code   In(Select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter))
End

Insert Into #TempAbs
Select ID.Product_Code [Detail Info],ID.Product_Code, I.ProductName, U.Description [UOM],
Cast((Sum(Isnull(Case @UOM
When 'UOM1' Then (ID.Quantity / IsNull(I.UOM1_Conversion, 1))
When 'UOM2' Then (ID.Quantity / IsNull(I.UOM2_Conversion, 1))
Else (ID.Quantity )	End
, 0))) as Decimal(18,6)) Qty,

--Cast((Sum(Isnull(((ID.Quantity) * (ID.SalePrice)), 0) + (STPayable + CSTPayable) )) as Decimal(18,6)) [Sales Value],
--Cast((Sum(Isnull(((ID.Quantity) * (ID.PTR)), 0) + (STPayable + CSTPayable) )) as Decimal(18,6))[PTR Value],
--Cast((Sum(Isnull(((ID.Quantity) * (ID.SalePrice)), 0) +  ((ID.Quantity * ID.SalePrice * Taxcode)/100) )) as Decimal(18,6)) [Sales Value],
--Cast((Sum(Isnull(((ID.Quantity) * (ID.PTR)), 0) + ((ID.Quantity * ID.PTR * Taxcode)/100) )) as Decimal(18,6))[PTR Value],

Sum(ID.Salevalue) [Sales Value], Sum(ID.PTRValue) [PTR Value],
GR.Division [Category],IC3.Category_Name [Sub Category],IC4.Category_Name [Market SKU]
,ID.CustomerID [Customer ID], C.Company_Name [Customer Name]
, Case When (Isnull(ID.QuotationID,0) > 0) Then Q.QuotationName
When (Isnull(ID.QuotationID,0) = 0) Then '' End [Quotation Name]
From #tmpFinalInvAbsDet ID, items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2
, UOM U, Customer C, QuotationAbstract Q,
tbl_mERP_OLClassMapping OLClsM, tbl_mERP_OLClass OLCls
Where IC4.categoryid = i.categoryid
And IC4.ParentId = IC3.categoryid
And IC3.ParentId = IC2.categoryid
And IC2.Category_Name = GR.Division
And GR.Division In(Select Distinct Category From #tempCategory)
And I.Product_code In(Select Distinct Product_Code From #tempItem)
And I.Product_code = ID.Product_code
And Isnull(ID.QuotationID,0) > 0
And C.CustomerID = ID.CustomerID
And Q.QuotationID = Isnull(ID.QuotationID,0)
And U.Active = 1
And U.UOM = (Select Case @UOM When 'Base UOM' Then I.UOM When 'UOM1' Then I.UOM1 When 'UOM2' Then I.UOM2 End)
--And C.ChannelType Not in(Select ChannelType From Customer_Channel Where ChannelDesc = 'WD')
And Q.QuotationType Not in(4)
And OLClsM.CustomerID = C.CustomerID And OLClsM.Active = 1
And OLCls.ID = OLClsM.OLClassID And OLCls.Channel_Type_Desc Not In ('WD')
Group By ID.Product_code ,I.ProductName,GR.Division ,IC3.Category_Name,IC4.Category_Name,U.Description
,ID.CustomerID, C.Company_Name,ID.QuotationID,Q.QuotationName

Select [Detail Info],@WDCode [WD Code],@WDDest [WD Dest],@FromDate [From Date], @ToDate [To Date], [Item Code],[Item Name],[UOM],
[Category],[Sub Category], [Market SKU], [Customer ID], [Customer Name], [Qty], [Sales Value], [PTR Value], [Quotation Name]
From #TempAbs

Drop table #tempCategory
Drop table #TempAbs
Drop table #tempItem
Drop Table #tmpInvAbsDet
Drop Table #tmpFinalInvAbsDet

OvernOut:
End
