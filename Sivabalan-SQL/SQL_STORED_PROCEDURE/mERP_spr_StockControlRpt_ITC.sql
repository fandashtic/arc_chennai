Create PROCEDURE mERP_spr_StockControlRpt_ITC
(
@Division NVarchar(2550),
@ItemCode NVarChar(2550),
@FROMDATE datetime,
@TODATE datetime,
@UOM nVarchar(30)
)
As
set dateformat dmy
Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)

Declare @Last_Close_Date Datetime
Select @Last_Close_Date = Convert(Nvarchar(10),LastInventoryUpload,103) From Setup


Declare @WDCode NVarchar(255),@WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Begin
Set @WDDest= @WDCode
End
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End


Create table #tmpDiv(Division NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProd(product_code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #Products(Product_Code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
ProductName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, UOM int,
Division  NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalesReturnSaleableWithReference Decimal(18, 6) Default (0),
SalesReturnSaleableWithoutReference Decimal(18, 6) Default (0),
SalesReturnSaleableWithoutReferenceValue Decimal(18, 6) Default (0),
SalesReturnDDWithReference Decimal(18, 6) Default (0),
SalesReturnDDWithoutReference Decimal(18, 6) Default (0),
SalesReturnDDWithoutReferenceValue Decimal(18, 6) Default (0),
SalesToWD Decimal(18, 6) Default (0),
SalesToWDValue Decimal(18, 6) Default (0),
SalesToOthers Decimal(18, 6) Default (0),
SalesToOthersValue Decimal(18, 6) Default (0),
Active Int)
Create Table #Invoice(InvoiceID Int, InvoiceType Int, Status Int,
NewReference NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
NRef Int,
CustomerID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If (@Division = '%' Or @Division = 'all' Or @Division = 'ALL' Or @Division = '')
Insert into #tmpDiv select Category_Name From ItemCategories Where [Level] = 2
Else
Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)

If @ItemCode = '%'
Insert InTo #tmpProd Select Product_code From Items
Else
Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

-- new channel classifications added-------------------------------

Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #OLClassCustLink (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType Int, Active Int, [Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #OLClassMapping
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc,
olc.SubOutlet_Type_Desc
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And
olcm.Active = 1

Insert Into #OLClassCustLink
Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], @TOBEDEFINED),
IsNull(olcm.[Outlet Type], @TOBEDEFINED) , IsNull(olcm.[Loyalty Program], @TOBEDEFINED)
From #OLClassMapping olcm
Right Outer Join Customer C  On olcm.CustomerID = C.CustomerID

-------------------------------------------------------

--Filter Item details from item master

--Select Product_Code, ProductName, UOM, BrandName, Items.Active
--From Items, Brand
--Where Items.BrandID = Brand.BrandID And Brand.BrandName In
-- (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
-- Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)

Insert Into #Products (Product_Code, ProductName, UOM, Division, Active)

Select Product_Code, ProductName, UOM, ic3.Category_Name, its.Active
From Items its, ItemCategories ic1, ItemCategories ic2, ItemCategories ic3
Where its.CategoryID = ic1.CategoryID And ic1.ParentID = ic2.CategoryID And
ic2.ParentID = ic3.CategoryID And ic3.Category_Name In
(Select Division From #tmpDiv) And
its.Product_Code in (Select product_code from #tmpProd)


--Filter valid invoices for the given dates
Select InvoiceID, InvoiceType, Status, NewReference,
Cast( IsNull(Reverse(left(reverse(IsNull(NewReference,'')),
Case When PATINDEX( N'%[^0-9]%', Reverse(IsNull(newreference, ''))) > 0 Then PATINDEX( N'%[^0-9]%',Reverse(IsNull(NewReference, ''))) -1
Else Len(IsNull(NewReference, '')) End )) , 0)
As bigint) NRef, CustomerID Into #Invoice_tmp
From InvoiceAbstract
Where InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND (InvoiceAbstract.Status & 128) = 0
--And IsNull(InvoiceAbstract.GSTFlag,0) = 0

--select I.InvoiceId, max(Ia.InvoiceId) Orig_Id Into #tmpSRWithRef from #Invoice_tmp I Join Invoiceabstract Ia on I.Nref   = Ia.DocumentId
--where I.Invoicetype IN ( 4, 5, 6 )
--Group by I.InvoiceId

Insert Into #Invoice
Select Itmp.InvoiceID, Itmp.InvoiceType, Itmp.Status, Itmp.NewReference, case when Isnull(Itmp.NewReference,'') = '' then  0 else 1 end as NRef, Itmp.CustomerID
From Invoiceabstract Ia , #Invoice_tmp Itmp  where  Ia.InvoiceID = Itmp.InvoiceID And Ia.Invoicetype IN ( 4, 5, 6 )

--Insert Into #Invoice
--Select I_tmp.InvoiceID, I_tmp.InvoiceType, I_tmp.Status, I_tmp.NewReference,
--    ( Case When SR_Ref.InvoiceId Is Null Then 0 Else 1 End ) NRef, I_tmp.CustomerID
--From #Invoice_tmp I_tmp left outer join #tmpSRWithRef SR_Ref on I_tmp.InvoiceId = SR_Ref.InvoiceId

--Added For GST begin

--Select InvoiceID, InvoiceType, Status, NewReference,
--Cast( IsNull(Reverse(left(reverse(IsNull(NewReference,'')),
--        Case When PATINDEX( N'%[^0-9]%', Reverse(IsNull(newreference, ''))) > 0 Then PATINDEX( N'%[^0-9]%',Reverse(IsNull(NewReference, ''))) -1
--    Else Len(IsNull(NewReference, '')) End )) , 0)
--         As bigint) NRef, IsNull(GSTFullDocID,'') GSTFullDocID, CustomerID Into #InvoiceGST_tmp
--From InvoiceAbstract
--Where InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND (InvoiceAbstract.Status & 128) = 0
--And IsNull(InvoiceAbstract.GSTFlag,0) = 1

--select I.InvoiceId, max(Ia.InvoiceId) Orig_Id Into #tmpSRWithRefGST from #InvoiceGST_tmp I Join Invoiceabstract Ia
--On (Isnull(IA.GSTFullDocID,'') = Isnull(I.NewReference,'') OR I.Nref   = Ia.DocumentId  )
----on I.InvoiceID   = Ia.InvoiceID
----And (IA.ReferenceNumber In (Select SRInvoiceID From #InvoiceGST_tmp Where SRInvoiceID = IA.ReferenceNumber)
----	OR
----	(IA.GSTFullDocID in (Select SRInvoiceID From #InvoiceGST_tmp Where SRInvoiceID = IA.ReferenceNumber))  )
--where I.Invoicetype IN ( 4, 5, 6 )
--Group by I.InvoiceId

--Insert Into #Invoice
--Select Itmp.InvoiceID, Itmp.InvoiceType, Itmp.Status, Itmp.NewReference, case when Isnull(Itmp.NewReference,'') = '' then  0 else 1 end as NRef, Itmp.CustomerID
--From Invoiceabstract Ia , #InvoiceGST_tmp Itmp  where  Ia.InvoiceID = Itmp.InvoiceID And Ia.Invoicetype IN ( 4, 5, 6 )

--Insert Into #Invoice
--Select I_tmp.InvoiceID, I_tmp.InvoiceType, I_tmp.Status, I_tmp.NewReference,
--    ( Case When SR_Ref.InvoiceId Is Null Then 0 Else 1 End ) NRef, I_tmp.CustomerID
--From #InvoiceGST_tmp I_tmp left outer join #tmpSRWithRefGST SR_Ref on I_tmp.InvoiceId = SR_Ref.InvoiceId

--Added For GST End

Select "Product_Code" = InvoiceDetail.Product_Code,
"RSalesReturnSaleableWithReference" = Sum((Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) = 0 And
SalePrice > 0 And NRef > 0)
OR (#Invoice.InvoiceType = 5 And
SalePrice > 0 And NRef > 0)) Then Quantity Else 0 End)),
"RSalesReturnSaleableWithoutReference" = Sum((Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) = 0 And
SalePrice > 0 And NRef = 0)
OR (#Invoice.InvoiceType = 5 And
SalePrice > 0 And NRef = 0)) Then Quantity Else 0 End)),
"RSalesReturnDamagesWithReference" = Sum(Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) <> 0 And
SalePrice > 0 And NRef > 0)
OR (#Invoice.InvoiceType = 6 And
SalePrice > 0 And NRef > 0)) Then Quantity Else 0 End),
"RSalesReturnDamagesWithoutReference" = Sum(Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) <> 0 And
SalePrice > 0 And NRef = 0)
OR (#Invoice.InvoiceType = 6 And
SalePrice > 0 And NRef = 0)) Then Quantity Else 0 End),
"RSalesReturnSaleableWithoutReferenceValue" = Sum((Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) = 0 And
SalePrice > 0 And NRef = 0)
OR (#Invoice.InvoiceType = 5 And
SalePrice > 0 And NRef = 0)) Then (Quantity * SalePrice) Else 0 End)),
"RSalesReturnDamagesWithoutReferenceValue" = Sum(Case When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) <> 0 And
SalePrice > 0 And NRef = 0)
OR (#Invoice.InvoiceType = 6 And
SalePrice > 0 And NRef = 0)) Then (Quantity * SalePrice) Else 0 End),
"RSaleableIssuesWD" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice > 0 And OLC.[Channel Type] = 'WD')
Then Quantity Else 0 End),

"RFreeIssuesWD" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice = 0 And OLC.[Channel Type] = 'WD')
Then Quantity Else 0 End),
"RSaleableIssuesWDValue" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice > 0 And OLC.[Channel Type] ='WD')
Then (isnull(Quantity,0)* isnull(salePrice,0)) -
isnull(InvoiceDetail.DiscountValue,0) - isnull(((InvoiceDetail.Quantity * isnull(InvoiceDetail.SalePrice,0)-isnull(InvoiceDetail.DiscountValue,0))
*InvoiceAbstract.AdditionalDiscount)/100,0) Else 0 End),

"RFreeIssuesWDValue" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice = 0 And OLC.[Channel Type] = 'WD')
Then (isnull(Quantity,0)* isnull(salePrice,0))Else 0 End),

"RSaleableIssuesOthers" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice > 0 And OLC.[Channel Type] <> 'WD')
Then Quantity Else 0 End),

"RFreeIssuesOthers" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice = 0 And OLC.[Channel Type] <> 'WD')
Then Quantity Else 0 End),

"RSaleableIssuesOthersValue" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice > 0 And OLC.[Channel Type] <>'WD')
Then (isnull(Quantity,0)* isnull(salePrice,0)) - isnull(InvoiceDetail.DiscountValue,0) - isnull(((InvoiceDetail.Quantity * isnull(InvoiceDetail.SalePrice,0)-isnull(InvoiceDetail.DiscountValue,0))*InvoiceAbstract.AdditionalDiscount)/100,0)
Else 0 End),

"RFreeIssuesOthersValue" = Sum(Case When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice = 0 And OLC.[Channel Type] <> 'WD')
Then (isnull(Quantity,0)* isnull(salePrice,0))  Else 0 End)
Into #RetailInvoice
From #Products, #Invoice, InvoiceDetail, #OLClassCustLink OLC,InvoiceAbstract
Where #Invoice.InvoiceID = InvoiceDetail.InvoiceID AND InvoiceDetail.Product_Code = #Products.Product_Code AND InvoiceAbstract.InvoiceId=InvoiceDetail.InvoiceID And
#Invoice.CustomerID = OLC.CustomerID
Group By InvoiceDetail.Product_Code

Update #Products Set SalesReturnSaleableWithReference = SalesReturnSaleableWithReference + RSalesReturnSaleableWithReference,
SalesReturnSaleableWithoutReference = SalesReturnSaleableWithoutReference + RSalesReturnSaleableWithoutReference,
SalesReturnSaleableWithoutReferenceValue = SalesReturnSaleableWithoutReferenceValue + RSalesReturnSaleableWithoutReferenceValue,
SalesReturnDDWithReference = SalesReturnDDWithReference + RSalesReturnDamagesWithReference,
SalesReturnDDWithoutReference = SalesReturnDDWithoutReference + RSalesReturnDamagesWithoutReference,
SalesReturnDDWithoutReferenceValue = SalesReturnDDWithoutReferenceValue + RSalesReturnDamagesWithoutReferenceValue,
SalesToWD = SalesToWD + RSaleableIssuesWD + RFreeIssuesWD,
SalesToWDValue = SalesToWDValue + RSaleableIssuesWDValue + RFreeIssuesWDValue,
SalesToOthers = SalesToOthers + RSaleableIssuesOthers + RFreeIssuesOthers,
SalesToOthersValue = SalesToOthersValue + RSaleableIssuesOthersValue + RFreeIssuesOthersValue
From #Products, #RetailInvoice
Where #Products.Product_Code = #RetailInvoice.Product_Code

Drop Table #RetailInvoice

--Filter valid dispatches for the given dates
Create Table #Dispatch(DispatchID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #Dispatch Select DispatchID, CustomerID From DispatchAbstract
Where DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
AND (Isnull(DispatchAbstract.Status, 0) & 320) = 0


Select  "Product_Code" = #Products.Product_Code,
"DSaleableIssuesWD" = Sum(IsNull(Case When SalePrice > 0 And FlagWord <> 1 And [Channel Type] = 'WD'
Then Quantity Else 0 End, 0)),
"DSaleableIssuesWDValue" = Sum(IsNull(Case When SalePrice > 0 And FlagWord <> 1 And [Channel Type] = 'WD'
Then Quantity * isnull(SalePrice,0) Else 0 End, 0)),
"DFreeIssuesWD" = Sum(IsNull(Case When (SalePrice = 0 OR FlagWord = 1) And [Channel Type] = 'WD'
Then Quantity Else 0 End, 0)),
"DFreeIssuesWDValue" = Sum(IsNull(Case When (SalePrice = 0 OR FlagWord = 1) And [Channel Type] = 'WD'
Then Quantity * isnull(SalePrice,0) Else 0 End, 0)),
"DSaleableIssuesOthers" = Sum(IsNull(Case When SalePrice > 0 And FlagWord <> 1 And [Channel Type] <> 'WD'
Then Quantity Else 0 End, 0)),
"DSaleableIssuesOthersValue" = Sum(IsNull(Case When SalePrice > 0 And FlagWord <> 1 And [Channel Type] <> 'WD'
Then Quantity * isnull(SalePrice,0) Else 0 End, 0)),
"DFreeIssuesOthers" = Sum(IsNull(Case When (SalePrice = 0 OR FlagWord = 1) And [Channel Type] <> 'WD'
Then Quantity Else 0 End, 0)) ,
"DFreeIssuesOthersValue" = Sum(IsNull(Case When (SalePrice = 0 OR FlagWord = 1) And [Channel Type] <> 'WD'
Then Quantity * isnull(SalePrice,0) Else 0 End, 0))

Into #DispatchDetail
From #Products, #Dispatch, DispatchDetail, #OLClassCustLink OLC
Where #Dispatch.DispatchID = DispatchDetail.DispatchID
AND DispatchDetail.Product_Code = #Products.Product_Code And
#Dispatch.CustomerID = OLC.CustomerID
Group By #Products.Product_Code



--For calculating Discount value without Tax
Create Table #tmpDiscount (Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Discount decimal(18,6),Type int)

Create Table #tmpInvoiceAbstract(invoiceid int,AdditionalDiscount decimal (18,6))
Create Table #tmpInvoiceDetail(invoiceid int,Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Discountvalue decimal (18,6),DisValue decimal (18,6))
Create Table #tmpDispatchAbstract(invoiceid int, DispatchID int)
Create Table #tmpDispatchDetail(DispatchID int,Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SalePrice decimal (18,6),FlagWord int)


insert into #tmpDispatchAbstract (invoiceid, DispatchID)
Select Invoiceid,DispatchID from DispatchAbstract where dispatchid in (Select DispatchID from #Dispatch)

insert into #tmpDispatchDetail(DispatchID,Product_code)
Select distinct DispatchID,Product_code from DispatchDetail Where dispatchid in (Select dispatchID from #Dispatch)
And SalePrice > 0 And FlagWord <> 1

insert into #tmpInvoiceAbstract (invoiceid, AdditionalDiscount)
Select invoiceid, AdditionalDiscount from InvoiceAbstract where invoiceid  in (Select InvoiceID from #tmpDispatchAbstract)

insert into #tmpInvoiceDetail (invoiceid, Product_Code,Discountvalue,DisValue)
Select invoiceid,Product_Code,sum(Discountvalue),sum(isnull(Quantity,0) * isnull(SalePrice,0)-isnull(DiscountValue,0)) from InvoiceDetail
where invoiceid in (Select invoiceID from #tmpInvoiceAbstract)
Group by invoiceid,Product_Code

--select * from #tmpDispatchDetail
--select * from #tmpInvoiceDetail Idet
--select * from  #tmpInvoiceAbstract IA
--select * from  #tmpDispatchAbstract DA
--select * from  #Dispatch
--select * from  #tmpDispatchDetail DD
--select * from  #OLClassCustLink OLC
--
--Select DD.DispatchId,#DispatchDetail.Product_code,
--(
--
--((isnull(IDet.Discountvalue,0)+ DisValue)*IA.AdditionalDiscount/100))
--as Discount, case when [Channel Type] = 'WD'  then 1 else 2 end
--from #DispatchDetail, #tmpInvoiceDetail Idet, #tmpInvoiceAbstract IA,#tmpDispatchAbstract DA,#Dispatch,#OLClassCustLink OLC,#tmpDispatchDetail DD
--Where #Dispatch.DispatchID=DA.DispatchID
--And DA.InvoiceID = IA.invoiceID
--AND #Dispatch.CustomerID = OLC.CustomerID
----And #DispatchDetail.DispatchID=#Dispatch.DispatchID
--And DD.DispatchID=#Dispatch.DispatchID
--And DD.DispatchID=DA.DispatchID
--And IA.InvoiceID=IDet.InvoiceID
--And #DispatchDetail.Product_code=Idet.Product_code
----group by #DispatchDetail.Product_code,[Channel Type]

insert into #tmpDiscount (Product_code,Discount,Type)
Select #DispatchDetail.Product_code,
(Sum(
((DisValue*(IA.AdditionalDiscount/100))+DiscountValue)))
as Discount, case when [Channel Type] = 'WD'  then 1 else 2 end
from #DispatchDetail, #tmpInvoiceDetail Idet, #tmpInvoiceAbstract IA,#tmpDispatchAbstract DA,#Dispatch,#OLClassCustLink OLC,#tmpDispatchDetail DD
Where #Dispatch.DispatchID=DA.DispatchID
And DA.InvoiceID = IA.invoiceID
AND #Dispatch.CustomerID = OLC.CustomerID
--And #DispatchDetail.DispatchID=#Dispatch.DispatchID
And DD.DispatchID=#Dispatch.DispatchID
And DD.DispatchID=DA.DispatchID
And IA.InvoiceID=IDet.InvoiceID
And #DispatchDetail.Product_code=Idet.Product_code
And DD.Product_code=#DispatchDetail.Product_code
group by #DispatchDetail.Product_code,[Channel Type]

select Product_code,SUM(Discount) Discount,Type  into #tmpDiscountFinal from #tmpDiscount
group by Product_code,Type




--insert into #tmpDiscount (dispatchID,Product_code,Discount,Type)
--Select #DispatchDetail.DispatchId,#DispatchDetail.Product_code,(
--Sum( isnull(
--Case When DD.SalePrice > 0 And DD.FlagWord <> 1 And [Channel Type] <> 'WD'
--Then
--((isnull(IDet.DiscountValue,0) - isnull(IDet.DiscountValue,0)) *IA.AdditionalDiscount/100) else 0 end,0))) as Discount ,2
--from #DispatchDetail, InvoiceDetail Idet, InvoiceAbstract IA,DispatchAbstract DA,DispatchDetail,#Dispatch,#OLClassCustLink OLC,DispatchDetail DD
--Where #Dispatch.DispatchID=DA.DispatchID
--And DA.InvoiceID = IA.invoiceID
--And #DispatchDetail.DispatchID=#Dispatch.DispatchID
--And DD.DispatchID=#Dispatch.DispatchID
--And DD.DispatchID=DA.DispatchID
--And IA.InvoiceID=IDet.InvoiceID
--AND #Dispatch.CustomerID = OLC.CustomerID
--And #DispatchDetail.Product_code=Idet.Product_code
--group by #DispatchDetail.DispatchId,#DispatchDetail.Product_code


update #DispatchDetail set DSaleableIssuesWDValue = DSaleableIssuesWDValue - Discount
From #DispatchDetail,#tmpDiscountFinal where --#DispatchDetail.DispatchID=#tmpDiscount.DispatchID
--And
#DispatchDetail.Product_code=#tmpDiscountFinal.Product_code And Type =1

update #DispatchDetail set DSaleableIssuesOthersValue = DSaleableIssuesOthersValue - Discount
From #DispatchDetail,#tmpDiscountFinal where --#DispatchDetail.DispatchID=#tmpDiscount.DispatchID
--And
#DispatchDetail.Product_code=#tmpDiscountFinal.Product_code And Type =2

Drop table #tmpDiscount
Drop table #tmpDiscountFinal


Update #Products Set
SalesToWD = SalesToWD + DSaleableIssuesWD ,
SalesToWDValue = SalesToWDValue + DSaleableIssuesWDValue,
SalesToOthers = SalesToOthers + DSaleableIssuesOthers,
SalesToOthersValue = SalesToOthersValue + DSaleableIssuesOthersValue
From #Products, #DispatchDetail
Where #Products.Product_Code = #DispatchDetail.Product_Code

Drop Table #DispatchDetail

Drop Table #tmpInvoiceAbstract
Drop Table #tmpInvoiceDetail
Drop Table #tmpDispatchAbstract
Drop Table #tmpDispatchDetail

Declare @NEXT_DATE Datetime
Declare @CORRECTED_DATE Datetime

SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS NVarchar) + N'/'
+ CAST(DATEPART(mm, @TODATE) as NVarchar) + N'/'
+ cast(DATEPART(yyyy, @TODATE) AS NVarchar)

SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS NVarchar) + N'/'
+ CAST(DATEPART(mm, GETDATE()) as NVarchar) + N'/'
+ cast(DATEPART(yyyy, GETDATE()) AS NVarchar)

SELECT  "Active" = #Products.Active,
"WDCode"=@WDCode, "WDDest"=@WDDest,
"From Date" = @FROMDATE, "To Date" = @TODATE,
"SKU Code" = #Products.Product_Code, "SKU Description" = #Products.ProductName,
"Division" = #Products.Division,
"UOM" = IsNull((Select [Description] From UOM Where UOM = #Products.UOM), ''),
"Opening Stock on Hand" = (ISNULL(Opening_Quantity, 0) - (IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0))),
"Opening D&D" = (IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))),
"Total Opening Stock" = (ISNULL(Opening_Quantity, 0) - (IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0))) +
(IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))),
"Purchase from ITC" = (ISNULL((SELECT SUM((QuantityReceived - QuantityRejected) )
FROM GRNAbstract, GRNDetail WHERE GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = #Products.Product_Code
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0 And
(GRNAbstract.GRNStatus & 32) = 0 And VendorID = 'ITC001'), 0)),
"Purchase from Others" = (ISNULL((SELECT SUM((QuantityReceived - QuantityRejected))
FROM GRNAbstract, GRNDetail WHERE GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = #Products.Product_Code
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0 And
(GRNAbstract.GRNStatus & 32) = 0 And VendorID <> 'ITC001'), 0)),
"Purchase from Others Value"  = (ISNULL((Select SUM(isnull(BDet.Quantity,0) * isnull(BDet.Purchaseprice,0)) from GRNAbstract GAbs,BillDetail BDet
WHERE GAbs.BillID=BDet.BillId and GAbs.GRNDate BETWEEN @FROMDATE AND @TODATE And BDet.Product_Code = #Products.Product_Code And (GAbs.GRNStatus & 64) = 0 And
(GAbs.GRNStatus & 32) = 0 And VendorID <> 'ITC001'),0)),
"Sales Return Saleable with Reference" = SalesReturnSaleableWithReference,
"Sales Return Saleable without Reference" = SalesReturnSaleableWithoutReference,
"Sales Return Saleable without Reference Value" = SalesReturnSaleableWithoutReferenceValue,
"Stock Transfer In" = (IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.Status & 192 = 0  And StockTransferInDetail.Rate > 0
And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)),
"Total Receipts - Saleable Stock" = (ISNULL((SELECT SUM((QuantityReceived - QuantityRejected))
FROM GRNAbstract, GRNDetail WHERE GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = #Products.Product_Code
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0 And
(GRNAbstract.GRNStatus & 32) = 0), 0)) +

SalesReturnSaleableWithReference +

SalesReturnSaleableWithoutReference +

(IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.Status & 192 = 0  And StockTransferInDetail.Rate > 0
And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)),

"Sales Return D&D with Reference" = SalesReturnDDWithReference,

"Sales Return D&D  without Reference" = SalesReturnDDWithoutReference,
"Sales Return D&D without Reference Value" = SalesReturnDDWithoutReferenceValue,
"Godown Damages" = (ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Total Receipt D&D Stocks" = SalesReturnDDWithReference + SalesReturnDDWithoutReference +
(ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Sales" = SalesToOthers,

"Sales Value" =SalesToOthersValue,

"Sales to Others" = SalesToWD,

"Sales to Others Value" = SalesToWDValue,

"Total Sales" = SalesToWD + SalesToOthers,

"Purchase Return" = (ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnDetail.Rate > 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)),

"Stock Transfer Out" = (IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.Status & 192 = 0  And StockTransferOutDetail.Rate > 0
And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)),

"Total Issue" = SalesToWD + SalesToOthers +

(ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnDetail.Rate > 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) +

(IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.Status & 192 = 0 And StockTransferOutDetail.Rate > 0
And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)),

"Net Stock Adjustment - Saleable" = (ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Net Stock Adjustment Value - Saleable" = (ISNULL((SELECT SUM(((Batch_Products.PTS) *(StockAdjustment.Quantity - StockAdjustment.OldQty)))
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Net Stock Adjustment - D&D" = (ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3,4)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) > 0  And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Net Stock Adjustment Value - D&D" = (ISNULL((SELECT SUM(((Batch_Products.PTS) *(StockAdjustment.Quantity - StockAdjustment.OldQty)))
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3,4)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) > 0  And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"D&D Flushed Out" = (IsNull((Select Sum(IsNull(DestroyQuantity, 0)) From StockDestructionAbstract sda,
StockDestructionDetail sdd, Batch_Products bp Where sda.DocSerial = sdd.DocSerial And
sdd.BatchCode = bp.Batch_Code And IsNull(bp.free, 0) = 0 And
sdd.Product_Code = #Products.Product_Code And
sda.DocumentDate Between @FROMDATE AND @TODATE), 0)),

-- D&D Flushed out Value taken from StockDestruction (Purchase Rate + Tax)

--"D&D Flushed Out Value" = (IsNull((Select Case Max(Isnull(TOQ,0)) When 0 then  Sum(((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) + (((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) * (IsNull(BP.Taxsuffered, 0)/100))) Else
--Sum(((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) + (((IsNull(SDD.DestroyQuantity, 0))) * (IsNull(BP.Taxsuffered, 0)))) End
-- From StockDestructionAbstract SDA, StockDestructionDetail SDD, Batch_Products BP
-- Where SDA.DocSerial = SDD.DocSerial And
-- SDD.BatchCode = BP.Batch_Code And IsNull(BP.free, 0) = 0 And
-- SDD.Product_Code = #Products.Product_Code And
-- SDA.DocumentDate Between @FROMDATE AND @TODATE), 0)),


"D&D Flushed Out Value" = (IsNull((
Select Case When Max(isNull(DA.Flag,0)) = 0 Then
Case Max(Isnull(TOQ,0)) When 0 then  Sum(((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) + (((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) * (IsNull(BP.Taxsuffered, 0)/100)))
Else Sum(((BP.PTS) * (IsNull(SDD.DestroyQuantity, 0))) + (((IsNull(SDD.DestroyQuantity, 0))) * (IsNull(BP.Taxsuffered, 0)))) End
Else SUM(isNull(BatchRFAValue,0)) End
From StockDestructionAbstract SDA, StockDestructionDetail SDD, Batch_Products BP, DandDAbstract DA, DandDDetail DD
Where SDA.DocSerial = SDD.DocSerial
and SDA.ClaimID = DA.ClaimID
and DA.ID = DD.ID
and DD.Batch_Code =  SDD.BatchCode
and SDD.BatchCode = BP.Batch_Code And IsNull(BP.Free, 0) = 0
and SDD.Product_Code = #Products.Product_Code
and SDA.DocumentDate Between @FROMDATE AND @TODATE), 0)),

"Closing Stock - Saleable" = (ISNULL(Opening_Quantity, 0) - (IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0))) +

((ISNULL((SELECT SUM((QuantityReceived - QuantityRejected))
FROM GRNAbstract, GRNDetail WHERE GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = #Products.Product_Code
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0 And
(GRNAbstract.GRNStatus & 32) = 0), 0)) +

SalesReturnSaleableWithReference +

SalesReturnSaleableWithoutReference +

(IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.Status & 192 = 0  And StockTransferInDetail.Rate > 0
And StockTransferInDetail.Product_Code = #Products.Product_Code), 0))) -


/*Subtract Stock Conversion Free to Saleable*/
(ISNULL((SELECT SUM(ConversionDetail.Quantity)
FROM ConversionAbstract, ConversionDetail, Batch_Products
WHERE ISNULL(ConversionType,0) = 2
And ConversionDetail.Product_Code = #Products.Product_Code
AND ConversionAbstract.DocSerial = ConversionDetail.DocSerial
AND ConversionDetail.OldBatchCode = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And ConversionDetail.PurchasePrice = 0
AND ConversionAbstract.DocumentDate BETWEEN @FROMDATE AND @TODATE), 0)) +

/*Add Stock Conversion Saleable to Free*/
(ISNULL((SELECT SUM(ConversionDetail.Quantity)
FROM ConversionAbstract, ConversionDetail, Batch_Products
WHERE ISNULL(ConversionType,0) = 1
And ConversionDetail.Product_Code = #Products.Product_Code
AND ConversionAbstract.DocSerial = ConversionDetail.DocSerial
AND ConversionDetail.NewBatchCode = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And ConversionDetail.PurchasePrice > 0
AND ConversionAbstract.DocumentDate BETWEEN @FROMDATE AND @TODATE), 0)) -

(SalesToWD + SalesToOthers +

(ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnDetail.Rate > 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) +

(IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.Status & 192 = 0 And StockTransferOutDetail.Rate > 0
And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0))) +

(ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))

-

(ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),

"Closing Stock - D&D" = (IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))) +

(SalesReturnDDWithReference + SalesReturnDDWithoutReference +

(ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))) +

(ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) > 0
And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) -

(IsNull((Select Sum(IsNull(DestroyQuantity, 0)) From StockDestructionAbstract sda,
StockDestructionDetail sdd, Batch_Products bp Where sda.DocSerial = sdd.DocSerial And
sdd.Product_Code = #Products.Product_Code And
sdd.BatchCode = bp.Batch_Code And IsNull(bp.Free, 0) = 0 And
sda.DocumentDate Between @FROMDATE AND @TODATE), 0))  +

(ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (4)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) > 0
And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate Between @FROMDATE AND @TODATE), 0))   ,

"ClosingStockD&DValueWithoutTax"= Cast(0 as Decimal(18,6)),

"ClosingStockD&DTaxValue"= Cast(0 as Decimal(18,6)),

"Total Closing Stock" = ((ISNULL(Opening_Quantity, 0) - (IsNull(Damage_Opening_Quantity, 0) + IsNull(Free_Saleable_Quantity, 0))) +

((ISNULL((SELECT SUM((QuantityReceived - QuantityRejected))
FROM GRNAbstract, GRNDetail WHERE GRNAbstract.GRNID = GRNDetail.GRNID
AND GRNDetail.Product_Code = #Products.Product_Code
AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And (GRNAbstract.GRNStatus & 64) = 0 And
(GRNAbstract.GRNStatus & 32) = 0), 0)) +

SalesReturnSaleableWithReference +

SalesReturnSaleableWithoutReference +

(IsNull((Select Sum(Quantity)
From StockTransferInAbstract, StockTransferInDetail
Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial
And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferInAbstract.Status & 192 = 0  And StockTransferInDetail.Rate > 0
And StockTransferInDetail.Product_Code = #Products.Product_Code), 0))) -


/*Subtract Stock Conversion Free to Saleable*/
(ISNULL((SELECT SUM(ConversionDetail.Quantity)
FROM ConversionAbstract, ConversionDetail, Batch_Products
WHERE ISNULL(ConversionType,0) = 2
And ConversionDetail.Product_Code = #Products.Product_Code
AND ConversionAbstract.DocSerial = ConversionDetail.DocSerial
AND ConversionDetail.OldBatchCode = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And ConversionDetail.PurchasePrice = 0
AND ConversionAbstract.DocumentDate BETWEEN @FROMDATE AND @TODATE), 0)) +

/*Add Stock Conversion Saleable to Free*/
(ISNULL((SELECT SUM(ConversionDetail.Quantity)
FROM ConversionAbstract, ConversionDetail, Batch_Products
WHERE ISNULL(ConversionType,0) = 1
And ConversionDetail.Product_Code = #Products.Product_Code
AND ConversionAbstract.DocSerial = ConversionDetail.DocSerial
AND ConversionDetail.NewBatchCode = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And ConversionDetail.PurchasePrice > 0
AND ConversionAbstract.DocumentDate BETWEEN @FROMDATE AND @TODATE), 0)) -

(SalesToWD + SalesToOthers +

(ISNULL((SELECT SUM(Quantity)
FROM AdjustmentReturnDetail, AdjustmentReturnAbstract
WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code
AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE
And AdjustmentReturnDetail.Rate > 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) +

(IsNull((Select Sum(Quantity)
From StockTransferOutAbstract, StockTransferOutDetail
Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial
And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate
And StockTransferOutAbstract.Status & 192 = 0 And StockTransferOutDetail.Rate > 0
And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0))) +

(ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) = 0 And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))

-

(ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))) +

((IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))) +

(SalesReturnDDWithReference + SalesReturnDDWithoutReference +

(ISNULL((SELECT SUM(StockAdjustment.Quantity)
FROM StockAdjustment, StockAdjustmentAbstract
WHERE ISNULL(AdjustmentType,0) in (0)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
And StockAdjustment.Rate > 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))) +

(ISNULL((SELECT SUM(StockAdjustment.Quantity - StockAdjustment.OldQty)
FROM StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (1, 3, 4)
And StockAdjustment.Product_Code = #Products.Product_Code
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
And IsNull(Batch_Products.Damage, 0) > 0
And (StockAdjustment.Rate - StockAdjustment.OldValue) <> 0
AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) -

(IsNull((Select Sum(IsNull(DestroyQuantity, 0)) From StockDestructionAbstract sda,
StockDestructionDetail sdd, Batch_Products bp Where sda.DocSerial = sdd.DocSerial And
sdd.Product_Code = #Products.Product_Code And
sdd.BatchCode = bp.Batch_Code And IsNull(bp.Free, 0) = 0 And
sda.DocumentDate Between @FROMDATE AND @TODATE), 0))),

"SIT" = IsNull((Select Sum(IsNull(IDR.pending, 0))
From InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
Where IDR.Product_code = #Products.Product_Code And IAR.Status & 64 = 0 And
IAR.InvoiceId = IDR.InvoiceId And Isnull(IDR.saleprice, 0) > 0), 0)

InTo #tmpFinalResult
FROM #Products
Left Outer Join OpeningDetails On #Products.Product_Code = OpeningDetails.Product_Code
Left Outer Join UOM On #Products.UOM = UOM.UOM
WHERE OpeningDetails.Opening_Date = @FROMDATE
--Start: Closing Stock D&D Value
Declare @OpeningDate Datetime
Select Top 1 @OpeningDate = OpeningDate From Setup

Create table #Batch(Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL, Batch_Code int,
QuantityReceived Decimal(18,6),Quantity Decimal(18,6),PTS Decimal(18,6), TaxSuffered Decimal(18,6),
DocDate DateTime, TOQ int,CS_TaxCode int,GRNTaxID int,GSTTaxType int,Sale_Tax int)

Create table #StkAdj (Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
Batch_Code int,
AdjQty decimal(18,6))


Create table #Destruction (Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
Batch_Code int,
DesQty decimal(18,6))

Create table #StkAdj1 (Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
Batch_Code int,
AdjQty decimal(18,6))

Create table #Destruction1 (Product_Code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
Batch_Code int,
DesQty decimal(18,6))


Insert Into #StkAdj1
Select Batch_Products.Product_Code, Batch_Products.Batch_Code,
SUM(IsNUll(StockAdjustment.Quantity, 0) - IsNull(StockAdjustment.OldQty, 0)) As AdjQty
From StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (4)
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
AND StockAdjustment.Product_Code = Batch_Products.Product_Code
And IsNull(Batch_Products.Damage, 0) <> 0
AND ISNULL(Batch_Products.Free,0) = 0
--And dbo.StripTimeFromDate(AdjustmentDate) <= @TODATE
Group By Batch_Products.Product_Code, Batch_Products.Batch_Code

Insert Into #Destruction1
Select BP.Product_Code, BP.Batch_Code, Sum(IsNull(SDD.DestroyQuantity, 0)) as DesQty
From StockDestructionAbstract SDA, StockDestructionDetail SDD, Batch_Products BP
Where SDA.DocSerial = SDD.DocSerial And
SDD.BatchCode = BP.Batch_Code And SDD.Product_Code = BP.Product_Code and IsNull(BP.Free, 0) = 0
--and SDA.DocumentDate <= @TODATE
Group By BP.Product_Code, BP.Batch_Code


Insert Into #StkAdj
Select Batch_Products.Product_Code, Batch_Products.Batch_Code,
SUM(IsNUll(StockAdjustment.Quantity, 0) - IsNull(StockAdjustment.OldQty, 0)) As AdjQty
From StockAdjustment, StockAdjustmentAbstract, Batch_Products
WHERE ISNULL(AdjustmentType,0) in (4)
AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID
AND StockAdjustment.Batch_Code = Batch_Products.Batch_Code
AND StockAdjustment.Product_Code = Batch_Products.Product_Code
And IsNull(Batch_Products.Damage, 0) <> 0
AND ISNULL(Batch_Products.Free,0) = 0
And dbo.StripTimeFromDate(AdjustmentDate) <= @TODATE
Group By Batch_Products.Product_Code, Batch_Products.Batch_Code

Insert Into #Destruction
Select BP.Product_Code, BP.Batch_Code, Sum(IsNull(SDD.DestroyQuantity, 0)) as DesQty
From StockDestructionAbstract SDA, StockDestructionDetail SDD, Batch_Products BP
Where SDA.DocSerial = SDD.DocSerial And
SDD.BatchCode = BP.Batch_Code And SDD.Product_Code = BP.Product_Code and IsNull(BP.Free, 0) = 0
and SDA.DocumentDate <= @TODATE
Group By BP.Product_Code, BP.Batch_Code

Insert into #Batch
Select Batch_Products.Product_Code, Batch_Code, isnull(QuantityReceived,0), isnull(Quantity,0),
Case when (Isnull(Batch_products.PFM,0) <= 0) then Isnull(Batch_Products.PTS,0)  Else  Isnull(Batch_products.PFM,0)  End As PTS,
Batch_Products.TaxSuffered, DocDate, isnull(TOQ,0),Isnull(CS_TaxCode,0) ,Isnull(GRNTaxID,0) ,Isnull(GSTTaxType,0),
Isnull(Items.Sale_Tax,0)
From Batch_Products Inner Join Items ON Batch_Products.Product_Code = Items.Product_Code
Left outer Join Tax ON  Items.Sale_Tax = Tax.Tax_Code
Where dbo.StripTimeFromDate(DocDate) <= @TODATE	And IsNull(Damage,0)<>0 AND ISNULL(Free,0) = 0 ---and  Batch_Products.GRNTaxID *= Tax.Tax_Code
Group by Batch_Products.Product_Code, Batch_Products.Batch_Code,Batch_Products.QuantityReceived,Batch_Products.Quantity,Batch_Products.PTS,Batch_Products.TaxSuffered,
Batch_Products.DocDate,Batch_Products.TOQ,Tax.CS_TaxCode,Batch_Products.GRNTaxID,Batch_Products.GSTTaxType,Items.Sale_Tax,Batch_Products.PFM


Update #Batch Set QuantityReceived = Quantity
Where Batch_Code not in(Select Distinct Batchcode From StockDestructionDetail
Group by Batchcode Having Sum(isnull(DestroyQuantity,0)) > 0)
and Batch_Code not in(Select Distinct Batch_code From StockAdjustment)
and dbo.StripTimeFromDate(DocDate) <= @OpeningDate

Update #Batch Set QuantityReceived = isnull(UpdQty, 0)
From #Batch,
(Select BP.Batch_Code, (Quantity + isnull(DesQty,0)) - isnull(AdjQty,0) as UpdQty
From #Batch BP
Left Outer Join #StkAdj1 StkAdj On BP.Product_Code = StkAdj.Product_Code And  BP.Batch_Code = StkAdj.Batch_Code
Left Outer Join #Destruction1 Destroy On BP.Product_Code = Destroy.Product_Code And BP.Batch_Code = Destroy.Batch_Code
Where dbo.StripTimeFromDate(DocDate) <= @OpeningDate) as Upd
Where Upd.Batch_Code = #Batch.Batch_Code

Update T Set [ClosingStockD&DValueWithoutTax] = Temp.CSDandDValue
From #tmpFinalResult T,
(
Select A.Product_Code, Sum(isnull(CSDandDValue,0)) as CSDandDValue From
(Select BP.Product_Code, BP.Batch_Code,

--Case  when (IsNull(BP.CS_TaxCode,0)> 0)  then



Sum((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0)))
--+ (IsNUll(BP.QuantityReceived,0)- IsNull(DesQty, 0) + IsNull(AdjQty, 0))
--*(dbo.Fn_openingbal_TaxCompCalc(BP.Product_Code,IsNull(BP.GRNTaxID,0),IsNull(BP.GSTTaxType,0),IsNull(BP.PTS,0),(Isnull(BP.PTS,0)*(IsNUll(BP.QuantityReceived,0)- IsNull(DesQty, 0) + IsNull(AdjQty, 0))),1,0)))


/*old
--Sum(((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) )) + (((BP.PTS) * (IsNull(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--*(dbo.Fn_openingbal_TaxCompCalc(BP.Product_Code,IsNull(BP.GRNTaxID,0),IsNull(BP.GSTTaxType,0),IsNull(BP.PTS,0),IsNull(BP.QuantityReceived,0),1,0))))
*/

--Else

--Case Isnull(BP.TOQ,0) When 0 Then
--(Case When Sum(((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	+ (((BP.PTS) * (IsNull(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	* (IsNull(BP.Taxsuffered, 0)/100)))  < 0 Then 0
--Else
--Sum(((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	+ (((BP.PTS) * (IsNull(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	* (IsNull(BP.Taxsuffered, 0)/100)))
--End)
--Else
--(Case When Sum(((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	+ (((IsNull(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) )) * (IsNull(BP.Taxsuffered, 0))))  < 0 Then 0
--Else
--Sum(((BP.PTS) * (IsNUll(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) ))
--	+ (((IsNull(BP.QuantityReceived,0) - IsNull(DesQty, 0) + IsNull(AdjQty, 0) )) * (IsNull(BP.Taxsuffered, 0))))
--End)
--END

--End
as CSDandDValue
From #Batch BP
Left Outer Join (	Select Product_Code, Batch_Code, DesQty From #Destruction) Destroy On BP.Product_Code = Destroy.Product_Code 	And BP.Batch_Code = Destroy.Batch_Code
Left Outer Join (Select Product_Code, Batch_Code, AdjQty From #StkAdj)StkAdj On BP.Product_Code = StkAdj.Product_Code	 And BP.Batch_Code = StkAdj.Batch_Code
Where dbo.StripTimeFromDate(BP.DocDate) <= @TODATE
--And IsNull(BP.Damage,0)<>0
Group by BP.Product_code, BP.Batch_Code,Isnull(BP.TOQ,0),isnull(BP.CS_TaxCode,0)
)A
Group By A.Product_Code
) Temp
Where T.[SKU Code] = Temp.Product_code

--End: Closing Stock D&D Value

---- *Newly Added ClosingStockD&DTaxValue*-----------

Update T Set [ClosingStockD&DTaxValue] = Temp.CSDandDTaxValue
From #tmpFinalResult T,
(
Select A.Product_Code, Sum(isnull(CSDandDTaxValue,0)) as CSDandDTaxValue From
(Select BP.Product_Code, BP.Batch_Code,

Case  when (IsNull(BP.CS_TaxCode,0)> 0)  then

--Sum((dbo.Fn_openingbal_TaxCompCalc(BP.Product_Code,Isnull(Sale_Tax,0),1,IsNull(PTS,0),1,1,0)))
SUM((IsNUll(BP.QuantityReceived,0)- IsNull(DesQty, 0) + IsNull(AdjQty, 0)) *
(dbo.Fn_TaxCompCalc_CalamityCess(BP.Product_Code,Isnull(Sale_Tax,0),1,IsNull(PTS,0),1,1,0,0)))
Else 0

End as CSDandDTaxValue

From #Batch BP
Left outer Join (
Select Product_Code, Batch_Code, DesQty From #Destruction)Destroy on BP.Product_Code = Destroy.Product_Code and BP.Batch_Code = Destroy.Batch_Code
Left Outer Join (Select Product_Code, Batch_Code, AdjQty From #StkAdj)StkAdj on BP.Product_Code = StkAdj.Product_Code and BP.Batch_Code = StkAdj.Batch_Code
Where dbo.StripTimeFromDate(BP.DocDate) <= @TODATE

--From #Batch BP,
--(
--Select Product_Code, Batch_Code, DesQty From #Destruction
--)Destroy,

--(
--Select Product_Code, Batch_Code, AdjQty From #StkAdj
--)StkAdj
--Where
--	BP.Product_Code *= Destroy.Product_Code
--	And BP.Batch_Code *= Destroy.Batch_Code
--	And BP.Product_Code *= StkAdj.Product_Code
--	And BP.Batch_Code *= StkAdj.Batch_Code
--And dbo.StripTimeFromDate(BP.DocDate) <= @TODATE
----And IsNull(BP.Damage,0)<>0
Group by BP.Product_code, BP.Batch_Code,Isnull(BP.TOQ,0),isnull(BP.CS_TaxCode,0)
)A
Group By A.Product_Code
) Temp
Where T.[SKU Code] = Temp.Product_code
--End: Closing Stock D&D Tax Value

Select
#tmpFinalResult.[Active],
[WDCode],
[WDDest],
[From Date],
[To Date],
[SKU Code],
[SKU Description],
[Division],
"UOM" = CASE @UOM	WHEN 'Base UOM' THEN  (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =I.UOM)
WHEN 'UOM 1' THEN (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =I.UOM1)
ELSE (Select CAST(UOM.Description AS nvarchar)  from UOM where UOM =I.UOM2)
END,

"Opening Stock on Hand" = CASE @UOM	WHEN 'Base UOM' THEN Isnull([Opening Stock on Hand],0)
WHEN 'UOM 1' THEN Cast(Isnull([Opening Stock on Hand],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Opening Stock on Hand],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Opening D&D" = CASE @UOM	WHEN 'Base UOM' THEN Isnull([Opening D&D],0)
WHEN 'UOM 1' THEN Cast(Isnull([Opening D&D],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Opening D&D],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Total Opening Stock" = CASE @UOM	WHEN 'Base UOM' THEN Isnull([Total Opening Stock],0)
WHEN 'UOM 1' THEN Cast(Isnull([Total Opening Stock],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Total Opening Stock],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Purchase from ITC" = CASE @UOM	WHEN 'Base UOM' THEN Isnull([Purchase from ITC],0)
WHEN 'UOM 1' THEN Cast(Isnull([Purchase from ITC],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Purchase from ITC],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Purchase from Others" = CASE @UOM	WHEN 'Base UOM' THEN Isnull([Purchase from Others],0)
WHEN 'UOM 1' THEN Cast(Isnull([Purchase from Others],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Purchase from Others],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Purchase from Others Value" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Purchase from Others Value],0)
WHEN 'UOM 1' THEN Cast(Isnull([Purchase from Others Value],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Purchase from Others Value],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
[Sales Return Saleable with Reference],
[Sales Return Saleable without Reference],
[Sales Return Saleable without Reference Value],
"Stock Transfer In" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Stock Transfer In],0)
WHEN 'UOM 1' THEN Cast(Isnull([Stock Transfer In],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Stock Transfer In],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Total Receipts - Saleable Stock" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Total Receipts - Saleable Stock],0)
WHEN 'UOM 1' THEN Cast(Isnull([Total Receipts - Saleable Stock],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Total Receipts - Saleable Stock],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Sales Return D&D with Reference" = Isnull([Sales Return D&D with Reference],0),
"Sales Return D&D  without Reference" = Isnull([Sales Return D&D  without Reference],0),
"Sales Return D&D without Reference Value" = Isnull([Sales Return D&D without Reference Value],0),
"Godown Damages" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Godown Damages],0)
WHEN 'UOM 1' THEN Cast(Isnull([Godown Damages],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Godown Damages],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Total Receipt D&D Stocks" =  CASE @UOM WHEN 'Base UOM' THEN Isnull([Total Receipt D&D Stocks],0)
WHEN 'UOM 1' THEN Cast(Isnull([Total Receipt D&D Stocks],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Total Receipt D&D Stocks],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Sales" = Isnull([Sales],0),
"Sales Value" = Isnull([Sales Value],0),
"Sales to Others" = Isnull([Sales to Others],0),
"Sales to Others Value" = Isnull([Sales to Others Value],0),
"Total Sales" = Isnull([Total Sales],0),
"Purchase Return" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Purchase Return],0)
WHEN 'UOM 1' THEN Cast(Isnull([Purchase Return],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Purchase Return],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Stock Transfer Out" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Stock Transfer Out],0)
WHEN 'UOM 1' THEN Cast(Isnull([Stock Transfer Out],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Stock Transfer Out],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Total Issue" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Total Issue],0)
WHEN 'UOM 1' THEN Cast(Isnull([Total Issue],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Total Issue],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Net Stock Adjustment - Saleable" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Net Stock Adjustment - Saleable],0)
WHEN 'UOM 1' THEN Cast(Isnull([Net Stock Adjustment - Saleable],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Net Stock Adjustment - Saleable],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Net Stock Adjustment Value - Saleable" = Isnull([Net Stock Adjustment Value - Saleable],0),
"Net Stock Adjustment - D&D" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Net Stock Adjustment - D&D],0)
WHEN 'UOM 1' THEN Cast(Isnull([Net Stock Adjustment - D&D],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Net Stock Adjustment - D&D],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Net Stock Adjustment Value - D&D" = Isnull([Net Stock Adjustment Value - D&D],0),
"D&D Flushed Out" = CASE @UOM WHEN 'Base UOM' THEN Isnull([D&D Flushed Out],0)
WHEN 'UOM 1' THEN Cast(Isnull([D&D Flushed Out],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([D&D Flushed Out],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"D&D Flushed Out Value" = Isnull([D&D Flushed Out Value],0),
"Closing Stock - Saleable" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Closing Stock - Saleable],0)
WHEN 'UOM 1' THEN Cast(Isnull([Closing Stock - Saleable],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Closing Stock - Saleable],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"Closing Stock - D&D" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Closing Stock - D&D],0)
WHEN 'UOM 1' THEN Cast(Isnull([Closing Stock - D&D],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Closing Stock - D&D],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"ClosingStockD&DValueWithoutTax" = Isnull([ClosingStockD&DValueWithoutTax],0),
"ClosingStockD&DTaxValue" = Isnull([ClosingStockD&DTaxValue],0),
"Total Closing Stock" = CASE @UOM WHEN 'Base UOM' THEN Isnull([Total Closing Stock],0)
WHEN 'UOM 1' THEN Cast(Isnull([Total Closing Stock],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([Total Closing Stock],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END,
"SIT" = CASE @UOM WHEN 'Base UOM' THEN Isnull([SIT],0)
WHEN 'UOM 1' THEN Cast(Isnull([SIT],0) / (Case IsNull(I.UOM1_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM1_Conversion,1) End) As Decimal(18,6))
ELSE Cast(Isnull([SIT],0) / (Case IsNull(I.UOM2_Conversion, 0) When 0 Then 1 Else IsNull(I.UOM2_Conversion,1) End) As Decimal(18,6))
END
From #tmpFinalResult
Inner Join Items I on #tmpFinalResult.[SKU Code] = I.Product_Code
Where ([Opening Stock on Hand] > 0 Or [Opening D&D] > 0 Or [Total Opening Stock] > 0 Or
[Purchase from ITC] > 0 Or [Purchase from Others] > 0 Or [Purchase from Others Value] > 0 Or [Sales Return Saleable with Reference] > 0 Or
[Sales Return Saleable without Reference] > 0 Or [Stock Transfer In] > 0 Or
[Total Receipts - Saleable Stock] > 0 Or [Sales Return D&D with Reference] > 0 Or
[Sales Return D&D  without Reference] > 0 Or [Godown Damages] > 0 Or
[Total Receipt D&D Stocks] > 0 Or [Sales] > 0 Or [Sales Value] > 0 Or [Sales to Others] > 0 Or [Sales to Others Value] > 0 or
[Total Sales] > 0 Or [Purchase Return] > 0 Or [Stock Transfer Out] > 0 Or
[Total Issue] > 0 Or [Net Stock Adjustment - Saleable] > 0 Or [Net Stock Adjustment Value - Saleable] > 0 or
[Net Stock Adjustment - D&D] > 0 Or [Net Stock Adjustment Value - D&D] > 0 Or [D&D Flushed Out] > 0 Or
[Closing Stock - Saleable] > 0 Or [Closing Stock - D&D] > 0 Or   [ClosingStockD&DValueWithoutTax] > 0 or
[ClosingStockD&DTaxValue] > 0 or [Total Closing Stock] > 0 Or [SIT] > 0) Or #tmpFinalResult.[Active] = 1
Order By [Division], [SKU Code]


Drop Table #Dispatch
Drop Table #Invoice
Drop Table #Products
Drop table #tmpDiv
Drop Table #tmpFinalResult

Drop Table #StkAdj
Drop Table #Destruction
Drop Table #StkAdj1
Drop Table #Destruction1

Drop Table #Invoice_tmp
--Drop Table #InvoiceGST_tmp
--Drop Table #tmpSRWithRefGST
--Drop table #tmpSRWithRef
IF OBJECT_ID('tempdb..#tmpProd') IS NOT NULL
Drop Table #tmpProd

IF OBJECT_ID('tempdb..#OLClassMapping') IS NOT NULL
Drop Table #OLClassMapping

IF OBJECT_ID('tempdb..#OLClassCustLink') IS NOT NULL
Drop Table #OLClassCustLink

IF OBJECT_ID('tempdb..#Batch') IS NOT NULL
Drop Table #Batch
OvernOut:
