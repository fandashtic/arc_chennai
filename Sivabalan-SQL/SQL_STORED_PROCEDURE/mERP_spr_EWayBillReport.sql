Create Procedure [dbo].[mERP_spr_EWayBillReport]
(
@SALESMAN_NAME nvarchar(2550),
@BeatName nvarchar(2550),
@Customer nvarchar(2550),
@FROMDATE Datetime,
@TODATE Datetime,
@SKUorHSN nvarchar(15),
@SalesorSR nvarchar(100),
@UOM nVarchar(255),
@InvoiceNumber nvarchar(2550)
)
As

Begin

Set DateFormat DMY
Declare @DandDTODATE DateTime
Set @DandDTODATE =@TODATE

Declare @UTGSTFlag int

Set @FROMDATE = dbo.StripTimeFromDate(@FROMDATE)
Set @TODATE = dbo.StripTimeFromDate(@TODATE)

Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)

create table #tmpSale(Salesman_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @SALESMAN_NAME='%'
insert into #tmpSale select Salesman_Name from Salesman
else
insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME,@Delimeter)

Create table #tmpBeat(BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @BeatName=N'%'
insert into #tmpBeat select Description from Beat
else
insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatName,@Delimeter)

Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Customer='%'
Insert into #tmpCustomer select CustomerID from Customer
Else
Insert into #tmpCustomer Select CustomerID from Customer where Company_Name in (select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter))

Create table #tmpInvoiceNum(InvoiceNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpDandDInvoiceNum(InvoiceNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


IF @SalesorSR = 'D & D Delivery Challan'
Begin
IF @InvoiceNumber='%'
Insert into #tmpInvoiceNum Select ID From DandDAbstract
Else
Insert into #tmpInvoiceNum Select ID From DandDAbstract Where DocumentID in (Select * From dbo.sp_SplitIn2Rows(@InvoiceNumber,@Delimeter))
End
Else
Begin
IF @InvoiceNumber='%'
Insert into #tmpInvoiceNum Select Invoiceid From InvoiceAbstract
Else
Insert into #tmpInvoiceNum Select Invoiceid From InvoiceAbstract Where GSTFullDocID in (select * from dbo.sp_SplitIn2Rows(@InvoiceNumber,@Delimeter))

IF @InvoiceNumber='%'
Insert into #tmpDandDInvoiceNum Select DandDInvID From DandDInvAbstract
Else
Insert into #tmpDandDInvoiceNum Select DandDInvID From DandDInvAbstract Where GSTFullDocID in (select * from dbo.sp_SplitIn2Rows(@InvoiceNumber,@Delimeter))
End

Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

Create Table #TempEwaybill(
[IDS] Int Identity(1, 1),
[InvoiceID] Int,
[Supply Type] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Sub Type] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Doc Type] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Doc No] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Doc Date] DateTime,
[From_OtherPartyName] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_GSTIN] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_Address1] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_Address2] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_Place] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_Pin Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From_State] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Dispatch State] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_OtherPartyName] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_GSTIN] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_Address1] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_Address2] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_Place] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_Pin Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[To_State] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Ship to State] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Product] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Description] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[HSN] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Unit] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Quantity] Decimal(18,6),
[Assesable Value] Decimal(18,6),
[Tax Rate] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[CGST Amount] Decimal(18,6),
[SGST Amount] Decimal(18,6),
[IGST Amount] Decimal(18,6),
[CESS Amount] Decimal(18,6),
[Cess Non Advol Amount] Decimal(18,6),
[Others] Decimal(18,6),
[Total Invoice Value] Decimal(18,6),
[Trans Mode] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Distance (Km)] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Trans Name] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Trans ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Trans DocNo] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Trans Date] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Vehicle No] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Vehicle Type] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #TmpInvoiceAbs (InvoiceID int,InvoiceDate datetime,GSTFullDocID varchar(250),AdditionalDiscount decimal(18,6),[Supply Type] varchar(15),
[Sub Type] Varchar(50) ,[Doc Type] Varchar(50), [From_OtherPartyName] Varchar(150),[From_GSTIN] Varchar(15),[From_Address1] Varchar(256),[From_Address2] Varchar(256),
[From_Place] Varchar(50),[From_Pin Code] Varchar(50),[From_State] Varchar(256),[Dispatch State] Varchar(256), [To_OtherPartyName] Varchar(150),[To_GSTIN] Varchar(15),[To_Address1] Varchar(256),
[To_Address2] Varchar(256),[To_Place] Varchar(50),[To_Pin Code] Varchar(50),[To_State] Varchar(256), [Ship to State] Varchar(256),CSTaxType Int,TotalInvoiceValue decimal(18,6), GSTDOCID int, InvoiceType int)

IF @SalesorSR = 'Both Sales & Sales Return'
Begin
Insert into #TmpInvoiceAbs
Select InvoiceID,InvoiceDate,GSTFullDocID,AdditionalDiscount,"Supply Type" = 'Outward',"Sub Type" = 'Supply',"Doc Type" = 'Tax Invoice',
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select organisationTitle from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = '',"From_Pin Code" = '',"From_State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = Case When Isnull(IA.GSTIN,'') = '' Then 'URP' Else IA.GSTIN End,
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" =A.Area ,
"To_Pin Code" = C.Pincode ,
"To_State" = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode)
,"CSTaxType" = (Case When IA.FromStateCode = IA.ToStateCode Then 1 Else 2 End),
"TotalInvoiceValue" = IA.NetValue, IA.GSTDOCID, IA.InvoiceType
From InvoiceAbstract IA Join Customer C On C.CustomerID = IA.CustomerID Join Areas A On A.AreaID = C.AreaID
Join Salesman SM On SM.SalesmanID = IA.SalesmanID
Join #tmpSale TSM On TSM.Salesman_Name = SM.Salesman_Name
Join Beat B On B.BeatID = IA.BeatID
Join #tmpBeat TB On TB.BeatName = B.Description
Where isnull(Status,0) & 128 = 0  and isnull(GSTFlag,0) = 1
And dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE And InvoiceType In (1,3)
And C.CustomerID in (Select Customer from #tmpCustomer)
And IA.InvoiceID in (Select InvoiceNumber from #tmpInvoiceNum)
Union
Select InvoiceID,InvoiceDate,GSTFullDocID,AdditionalDiscount,"Supply Type" = 'Inward',"Sub Type" = 'Sales Return',"Doc Type" = 'Credit Note',
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = Case When Isnull(IA.GSTIN,'') = '' Then 'URP' Else IA.GSTIN End,
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = A.Area , "From_Pin Code" = C.Pincode ,"From_State" = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode) ,
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = IA.ToStateCode ),
"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(((select organisationTitle from setup)),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" = '',
"To_Pin Code" = '',
"To_State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = IA.FromStateCode)
,"CSTaxType" = (Case When IA.FromStateCode = IA.ToStateCode Then 1 Else 2 End),
"TotalInvoiceValue" = IA.NetValue, IA.GSTDOCID, IA.InvoiceType
From InvoiceAbstract IA Join Customer C On C.CustomerID = IA.CustomerID Join Areas A On A.AreaID = C.AreaID
Join Salesman SM On SM.SalesmanID = IA.SalesmanID
Join #tmpSale TSM On TSM.Salesman_Name = SM.Salesman_Name
Join Beat B On B.BeatID = IA.BeatID
Join #tmpBeat TB On TB.BeatName = B.Description
Where isnull(Status,0) & 128 = 0  and isnull(GSTFlag,0) = 1
And dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE And InvoiceType In (4)
And C.CustomerID in (Select Customer from #tmpCustomer)
And IA.InvoiceID in (Select InvoiceNumber from #tmpInvoiceNum)
End
Else IF @SalesorSR = 'Sales Return'
Begin
Insert into #TmpInvoiceAbs
Select InvoiceID,InvoiceDate,GSTFullDocID,AdditionalDiscount,"Supply Type" = 'Inward',"Sub Type" = 'Sales Return',"Doc Type" = 'Credit Note',
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = Case When Isnull(IA.GSTIN,'') = '' Then 'URP' Else IA.GSTIN End,
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = A.Area , "From_Pin Code" = C.Pincode ,"From_State" = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode) ,
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = IA.ToStateCode ),
"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select organisationTitle from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '), '=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" = '',
"To_Pin Code" = '',
"To_State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = IA.FromStateCode)
,"CSTaxType" = (Case When IA.FromStateCode = IA.ToStateCode Then 1 Else 2 End)	,
"TotalInvoiceValue" = IA.NetValue, IA.GSTDOCID, IA.InvoiceType
From InvoiceAbstract IA Join Customer C On C.CustomerID = IA.CustomerID Join Areas A On A.AreaID = C.AreaID
Join Salesman SM On SM.SalesmanID = IA.SalesmanID
Join #tmpSale TSM On TSM.Salesman_Name = SM.Salesman_Name
Join Beat B On B.BeatID = IA.BeatID
Join #tmpBeat TB On TB.BeatName = B.Description
Where isnull(Status,0) & 128 = 0  and isnull(GSTFlag,0) = 1
And dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE And InvoiceType In (4)
And C.CustomerID in (Select Customer from #tmpCustomer)
And IA.InvoiceID in (Select InvoiceNumber from #tmpInvoiceNum)
End
Else IF @SalesorSR = 'D & D Delivery Challan'
Begin

Create Table #TempDandDTaxComponents(DandDID int, Product_Code nvarchar(30), Batch_Code int, TaxType int, Tax_Code int, Tax_Component_Code int,
Tax_Percentage Decimal(18,6), Tax_Value Decimal(18,6))

Select DA.ID, DA.ClaimDate, DA.DocumentID, DA.ClaimStatus, DA.CustomerID, C.Company_Name, DA.FromStateCode, DA.ToStateCode, DA.GSTIN,
A.Area, C.Pincode, C.BillingAddress, C.ShippingAddress, DA.ClaimID
Into #TempDandDAbstract
From DandDAbstract DA
Inner Join Customer C ON DA.CustomerID = C.CustomerID
Left Join Areas A On A.AreaID = C.AreaID
Where dbo.StripTimeFromDate(DA.ClaimDate) BETWEEN @FROMDATE AND @TODATE and DA.ClaimStatus in(1,2)
And C.CustomerID in (Select Customer from #tmpCustomer)
And DA.ID in (Select InvoiceNumber from #tmpInvoiceNum)

Select DD.ID, DD.Product_Code, DD.Batch_Code, DD.TaxType, DD.TaxID, DD.TaxSuffered, DD.UOM,
--Case When DA.ClaimStatus = 1 Then DD.TotalQuantity Else DD.RFAQuantity End as RFAQuantity,
DD.TotalQuantity as RFAQuantity,
DD.TotalQuantity, UOMTotalQty,
--Case When DA.ClaimStatus = 1 Then DD.UOMTotalQty Else DD.UOMRFAQty End as UOMRFAQuantity,
DD.UOMTotalQty as UOMRFAQuantity,
UOMPTS, DD.PTS, DD.BatchTaxableAmount, DD.BatchRFAValue, DD.TaxAmount, Cast(0 as Decimal(18,6)) TotalAbsAmt
Into #TempDandDDetail
From #TempDandDAbstract DA
Inner Join DandDDetail DD ON DA.ID = DD.ID

Declare @i int,
@reccnt int,
@nTax_Code  int,
@nTaxComponent_code int,
@dTax_percentage  decimal(18,6),
@nCS_ComponentCode  int,
@nComponentType  int,
@nApplicableonComp  int,
@nApplicableOnCode int,
@nApplicableUOM int,
@dPartOff decimal(5,2),
@lFirstPoint int,
@nTaxOnAmt decimal(18,6),
@ntaxamount decimal(18,6),
@nTotTaxAmount decimal(18,6),
@uom1 decimal(18,6),
@uom2 decimal(18,6),
@TotalAmount Decimal(18,6),
@comp_taxamt Decimal(18,6),
@ID int,
@Product_code nvarchar(30)

Declare @BatchCode int,
@nQty Decimal(18,6),
@TaxSuff Decimal(18,6),
@PTS Decimal(18,6),
@TOQ int,
@GRNTaxID int,
@GRNTaxType int

Declare @GSTCSTaxCode int
Declare @nMultiplier Decimal(18,6)
Declare @TaxableAmount Decimal(18,6)
Declare @BatchAmount Decimal(18,6)

Set @nMultiplier = 1

Create Table #taxcompcalc
(
tmp_id	int identity(1,1),
tmp_Tax_Code	int,
tmp_TaxComponent_code	int,
tmp_Tax_percentage	decimal(18,6),
tmp_ApplicableOn	nvarchar(max),
tmp_SP_Percentage	decimal(18,6),
tmp_LST_Flag	int,
tmp_CS_ComponentCode	int,
tmp_ComponentType	int,
tmp_ApplicableonComp	int,
tmp_ApplicableOnCode	int,
tmp_ApplicableUOM	int,
tmp_PartOff	decimal(5,2),
tmp_TaxType	int,
tmp_FirstPoint	int,
tmp_GSTComponentCode	int,
tmp_CompLevel	int,
tmp_comp_taxamt	decimal(18,6)
)

Update #TempDandDDetail Set BatchTaxableAmount = isnull(PTS,0) * isnull(RFAQuantity,0) Where ID in(Select ID From #TempDandDAbstract Where ClaimStatus in(1,2))

Declare Cur Cursor FOR
Select DD.ID, DD.Product_code, DD.Batch_Code, DD.RFAQuantity, isnull(DD.TaxSuffered,0), DD.PTS, BP.TOQ, DD.TAXID, DD.TaxType,
BatchTaxableAmount, BatchTaxableAmount as BatchAmount
From #TempDandDDetail DD
Join Batch_Products BP ON DD.Product_Code = BP.Product_Code and DD.Batch_Code = BP.Batch_Code
Where ID in(Select ID From #TempDandDAbstract Where ClaimStatus in (1,2))

Open Cur
Fetch From Cur Into	@ID, @Product_code,@BatchCode,@nQty,@TaxSuff,@PTS,@TOQ,@GRNTaxID,@GRNTaxType,@TaxableAmount,@BatchAmount
While @@Fetch_status = 0
Begin
Set @GSTCSTaxCode = 0
Set @TotalAmount = 0
Set @nTotTaxAmount = 0
Set @ntaxamount = 0
Set @comp_taxamt = 0

Select @GSTCSTaxCode = CS_TaxCode From Tax Where Tax_Code = @GRNTaxID
IF @GSTCSTaxCode > 0
Begin
--Insert TaxComponents records into Temp table
Insert Into #taxcompcalc
(	tmp_Tax_Code		,	tmp_TaxComponent_code	,	tmp_Tax_percentage	,	tmp_ApplicableOn	,
tmp_SP_Percentage	,	tmp_LST_Flag			,	tmp_CS_ComponentCode,	tmp_ComponentType	,
tmp_ApplicableonComp,	tmp_ApplicableOnCode	,	tmp_ApplicableUOM	,	tmp_PartOff			,
tmp_TaxType			,	tmp_FirstPoint			,	tmp_GSTComponentCode,	tmp_CompLevel		,
tmp_comp_taxamt		)
Select
Tax_Code			,	TaxComponent_code		,	Tax_percentage		,	ApplicableOn		,
SP_Percentage		,	LST_Flag				,	CS_ComponentCode	,	ComponentType		,
ApplicableonComp	,	ApplicableOnCode		,	ApplicableUOM		,	PartOff				,
CSTaxType				,	FirstPoint				,	GSTComponentCode	,	CompLevel			,
0
From	TaxComponents (nolock)
Where	Tax_Code	= @GRNTaxID
And		CSTaxType		= @GRNTaxType
Order By CompLevel

Select @i = 1
Select @reccnt = max(tmp_id) From  #taxcompcalc

--Total Tax Calculation
IF (@reccnt <> 0 )
Begin
While(@i <= @reccnt)
Begin
Select 	@nTax_Code = tmp_Tax_Code,
@nTaxComponent_code = tmp_TaxComponent_code,
@dTax_percentage  = tmp_Tax_percentage,
@nCS_ComponentCode = tmp_CS_ComponentCode,
@nComponentType = tmp_ComponentType,
@nApplicableonComp = tmp_ApplicableonComp,
@nApplicableOnCode = tmp_ApplicableOnCode,
@nApplicableUOM =  tmp_ApplicableUOM,
@dPartOff =  tmp_PartOff,
@lFirstPoint = tmp_FirstPoint
From	#taxcompcalc
Where	tmp_id = @i

IF (@nApplicableonComp = 0)
Begin
IF (@nApplicableOnCode = 7)
Begin
Select @uom1 = UOM1_Conversion,
@uom2 = UOM2_Conversion
From Items (nolock)
Where Product_Code = @Product_code

Select @ntaxamount = Case @nApplicableUOM
When 1 then @nQty * @nMultiplier * @dTax_percentage
When 2 then ((@nQty * @nMultiplier) / @uom1) * @dTax_percentage
When 3 then ((@nQty * @nMultiplier) / @uom2) * @dTax_percentage
End
End

Else
Begin
--Select @nTaxOnAmt =	Case @dPartOff When 100 Then @PTS Else (@PTS * @dPartOff / 100) End
Select @ntaxamount = @TaxableAmount * (@dTax_percentage / 100)
End
End
Else
Begin
Select @comp_taxamt	= tmp_comp_taxamt
From   #taxcompcalc
--Where  tmp_ApplicableonComp = @nApplicableonComp
Where  tmp_CS_ComponentCode = @nApplicableonComp

Select @ntaxamount = @comp_taxamt * (@dTax_percentage / 100)
select @ntaxamount,@comp_taxamt,@nApplicableonComp
End

Insert Into #TempDandDTaxComponents(DandDID,Product_Code,Batch_Code,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
Select @ID,@Product_code,@BatchCode,@GRNTaxType,@nTax_Code,@nTaxComponent_code,@dTax_percentage,@ntaxamount

--Update component wise tax amount
Update	#taxcompcalc
Set		tmp_comp_taxamt =	@ntaxamount
Where	tmp_id = @i
and		tmp_ApplicableonComp = @nApplicableonComp

Select  @nTotTaxAmount = @nTotTaxAmount + @ntaxamount

Select @i = @i+1
End
End

End
Else
Begin
IF @TOQ = 1
Begin
Select @nTotTaxAmount = @nQty * @TaxSuff
End
Else
Begin
--Select @nTotTaxAmount = (@nQty * @PTS) * (@TaxSuff/100)
Select @nTotTaxAmount = @TaxableAmount * (@TaxSuff/100)
End
End

--Select @TotalAmount = (@nQty * @PTS) + @nTotTaxAmount
Select @TotalAmount = @BatchAmount + @nTotTaxAmount
Truncate Table #taxcompcalc

Update #TempDandDDetail Set TaxAmount = @nTotTaxAmount
Where ID = @ID and Product_Code = @Product_code and Batch_Code = @BatchCode

Fetch Next From Cur Into @ID, @Product_code, @BatchCode,@nQty,@TaxSuff,@PTS,@TOQ,@GRNTaxID,@GRNTaxType,@TaxableAmount,@BatchAmount
End
Close Cur
Deallocate Cur

Update #TempDandDDetail Set BatchRFAValue = (BatchTaxableAmount + isnull(TaxAmount,0))
Where ID in(Select Distinct ID From #TempDandDAbstract) --Where ClaimStatus = 1)

Update Tmp Set TotalAbsAmt = TotAmt
From #TempDandDDetail Tmp, (Select ID, Sum(isnull(BatchRFAValue,0)) as TotAmt From #TempDandDDetail Group By ID) Tot
Where Tmp.ID = Tot.ID

--Insert Into #TempDandDTaxComponents(DandDID,Product_Code,Batch_Code,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value)
--Select * From DandDTaxComponents Where DandDID in(Select Distinct ID From #TempDandDAbstract Where ClaimStatus = 2)

Select  DandDID, Product_Code, Batch_Code, Tax_Code,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value  Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End),
MRPPerPack=0 Into #TempDandDTaxDet
From #TempDandDTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Group By DandDID, Product_Code,Batch_Code , Tax_Code


Create Table #TmpDandD(ID int, Product_Code nvarchar(30), Quantity Decimal(18,6), UOM int, TaxableAmount Decimal(18,6), TotalAmount Decimal(18,6),
SGSTPer Decimal(18,6), SGSTAmt Decimal(18,6), CGSTPer Decimal(18,6), CGSTAmt Decimal(18,6), IGSTPer Decimal(18,6),
IGSTAmt Decimal(18,6), UTGSTPer Decimal(18,6), UTGSTAmt Decimal(18,6), CESSPer Decimal(18,6), CESSAmt Decimal(18,6),
ADDLCESSPer Decimal(18,6), ADDLCESSAmt Decimal(18,6), TaxID int, DiVName nvarchar(255))

Insert Into #TmpDandD(ID, Product_Code, Quantity, UOM, TaxableAmount, TotalAmount,	SGSTPer, SGSTAmt, CGSTPer, CGSTAmt, IGSTPer,
IGSTAmt, UTGSTPer, UTGSTAmt, CESSPer, CESSAmt,	ADDLCESSPer, ADDLCESSAmt, TaxID, DiVName)
Select ID.ID, ID.Product_Code, Sum(ID.RFAQuantity) Quantity, ID.UOM, Sum(isnull(ID.BatchTaxableAmount,0)), TotalAbsAmt,
SGSTPer= Max(Tmp.SGSTPer),
SGSTAmt= Sum(Tmp.SGSTAmt),
CGSTPer= Max(Tmp.CGSTPer),
CGSTAmt= Sum(Tmp.CGSTAmt),
IGSTPer= Max(Tmp.IGSTPer),
IGSTAmt= Sum(Tmp.IGSTAmt ),
UTGSTPer= Max(Tmp.UTGSTPer),
UTGSTAmt= Sum(Tmp.UTGSTAmt ),
CESSPer= Max(Tmp.CESSPer),
CESSAmt= Sum(Tmp.CESSAmt),
ADDLCESSPer= Max(Tmp.ADDLCESSPer),
ADDLCESSAmt= Sum(Tmp.ADDLCESSAmt),
ID.TaxID,
IC2.Description
From #TempDandDDetail ID Left Join #TempDandDTaxDet Tmp ON ID.ID = Tmp.DandDID and ID.Product_Code = Tmp.Product_Code
and ID.Batch_code = Tmp.Batch_Code
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Inner Join Items I ON ID.Product_Code = I.Product_Code
Inner Join ItemCategories IC4 ON IC4.CategoryID  = I.CategoryID
Inner Join ItemCategories IC3 ON IC4.Parentid = IC3.CategoryID
Inner Join ItemCategories IC2 ON IC3.Parentid = IC2.CategoryID
Group By ID.ID, ID.Product_Code,isnull(T.CS_TaxCode,0),ID.TaxID, ID.UOM, IC2.Description, TotalAbsAmt


Select DA.ID, 'Outward' [Supply Type], 'Supply' [Sub Type], 'Delivery Challan' [Doc Type],
"Doc No" = Isnull(DA.DocumentID,''), "Doc Date" = DA.ClaimDate,
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select organisationTitle from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = '',"From_Pin Code" = '',"From_State" = (select upper(StateName)  from statecode where StateID  = DA.FromStateCode ),
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = DA.FromStateCode ),
"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DA.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = Case When Isnull(DA.GSTIN,'') = '' Then 'URP' Else DA.GSTIN End,
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DA.BillingAddress, '^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" = DA.Area ,
"To_Pin Code" = DA.Pincode ,
"To_State" = (select Upper(StateName)  from statecode where StateID  = DA.ToStateCode),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = DA.ToStateCode),
"CSTaxType" = (Case When DA.FromStateCode = DA.ToStateCode Then 1 Else 2 End),
"Product" = Items.ProductName, "Description" = Items.ProductName, DD.DivName,
"HSN" = isnull(Items.HSNNumber,''),
"Unit" = (
Case When @UOM = 'UOM1' then (Case When U1.Description = 'CFC' Then 'BOX' When U1.Description = 'EA' Then 'UNITS' When U1.Description = 'KAR' Then 'BOX' When U1.Description = 'KG' Then 'KILOGRAMS' When U1.Description = 'L' Then 'LITRES' When U1.Description = 'M_S' Then 'THOUSANDS' When U1.Description = 'PAC' Then 'PIECES' End)
When @UOM = 'UOM2' then (Case When U2.Description = 'CFC' Then 'BOX' When U2.Description = 'EA' Then 'UNITS' When U2.Description = 'KAR' Then 'BOX' When U2.Description = 'KG' Then 'KILOGRAMS' When U2.Description = 'L' Then 'LITRES' When U2.Description = 'M_S' Then 'THOUSANDS' When U2.Description = 'PAC' Then 'PIECES' End)
Else (Case When U.Description = 'CFC' Then 'BOX' When U.Description = 'EA' Then 'UNITS' When U.Description = 'KAR' Then 'BOX' When U.Description = 'KG' Then 'KILOGRAMS' When U.Description = 'L' Then 'LITRES' When U.Description = 'M_S' Then 'THOUSANDS' When U.Description = 'PAC' Then 'PIECES' End)
END
),
"Quantity" = (
Case When @UOM = 'UOM1' then SUM(DD.Quantity)/Case When IsNull(Items.UOM1_Conversion, 1) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOM = 'UOM2' then SUM(DD.Quantity)/Case When IsNull(Items.UOM2_Conversion, 1) = 0 Then 1 Else Items.UOM2_Conversion End
Else SUM(DD.Quantity) / 1
End
),
"Assesable Value" = Sum(DD.TaxableAmount),
"Tax Rate" = cast(Case When @UTGSTFlag = 1 Then cast(isnull(DD.UTGSTPer,0) as decimal(18,2)) Else cast(isnull(DD.SGSTPer,0) as decimal(18,2)) End as varchar) +
'+' + cast(cast(isnull(DD.CGSTPer,0) as decimal(18,2)) as varchar) +
'+' + cast(cast(isnull(DD.IGSTPer,0) as decimal(18,2)) as varchar) +
'+' + cast(cast(isnull(DD.CESSPer,0) as decimal(18,2)) as Varchar) +
'+' + cast(cast(isnull(DD.ADDLCESSPer,0) as decimal(18,2)) as Varchar),
"CGST Amount" = Sum(isnull(DD.CGSTAmt,0)),
"SGST Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(DD.UTGSTAmt,0)) Else Sum(isnull(DD.SGSTAmt,0)) End,
"IGST Amount" = Sum(isnull(DD.IGSTAmt,0)),
"Cess Amount" = Sum(isnull(DD.CESSAmt,0)), --+ isnull(DD.ADDLCESSAmt,0)) ,
"Cess Non Advol Amount" = Sum(isnull(DD.ADDLCESSAmt,0)) ,
"Others" = 0 ,
"Total Invoice Value" = DD.TotalAmount,
"Trans Mode" = 'Road',
"Distance (Km)" = '',"Trans Name" = '',"Trans ID" = '',"Trans DocNo" = '',"Trans Date" = '', "Vehicle No" = '' ,"Vehicle Type" = 'Regular', DA.ClaimID
Into #TmpDandDFinalRptData
From #TempDandDAbstract DA
Inner Join #TmpDandD DD ON DA.ID = DD.ID
Inner Join Items ON DD.Product_Code = Items.Product_Code
Inner Join UOM U ON U.UOM = Items.UOM
Inner Join UOM U1 ON U1.UOM = Items.UOM1
Inner Join UOM U2 ON U2.UOM = Items.UOM2
Group By DA.ID,DA.ClaimDate,DA.DocumentID,
DD.Product_Code, Items.ProductName, isnull(Items.HSNNumber,''), DD.TaxID, DD.DivName,
DD.UTGSTPer, DD.SGSTPer, DD.CGSTPer, DD.IGSTPer, DD.CESSPer, DD.ADDLCESSPer, U.Description,U1.Description,U2.Description,Items.UOM1_Conversion,Items.UOM2_Conversion
,DA.FromStateCode, DA.ToStateCode, DA.Company_Name, Case When Isnull(DA.GSTIN,'') = '' Then 'URP' Else DA.GSTIN End,
DA.BillingAddress, DA.ShippingAddress, DA.Area, DA.PinCode, DD.TotalAmount,DA.ClaimID

Drop Table #TempDandDTaxComponents
Drop Table #taxcompcalc
Drop Table #TempDandDAbstract
Drop Table #TempDandDDetail
Drop Table #TempDandDTaxDet
Drop Table #TmpDandD

End
Else
Begin
Insert into #TmpInvoiceAbs
Select InvoiceID,InvoiceDate,GSTFullDocID,AdditionalDiscount,"Supply Type" = 'Outward',"Sub Type" = 'Supply',"Doc Type" = 'Tax Invoice',
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select organisationTitle from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = '',"From_Pin Code" = '',"From_State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),

"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = Case When Isnull(IA.GSTIN,'') = '' Then 'URP' Else IA.GSTIN End,
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" =A.Area ,
"To_Pin Code" = C.Pincode ,
"To_State" = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode)
,"CSTaxType" = (Case When IA.FromStateCode = IA.ToStateCode Then 1 Else 2 End)	,
"TotalInvoiceValue" = IA.NetValue, IA.GSTDOCID, IA.InvoiceType
From InvoiceAbstract IA Join Customer C On C.CustomerID = IA.CustomerID Join Areas A On A.AreaID = C.AreaID
Join Salesman SM On SM.SalesmanID = IA.SalesmanID
Join #tmpSale TSM On TSM.Salesman_Name = SM.Salesman_Name
Join Beat B On B.BeatID = IA.BeatID
Join #tmpBeat TB On TB.BeatName = B.Description
Where isnull(Status,0) & 128 = 0  and isnull(GSTFlag,0) = 1
And dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE And InvoiceType In (1,3)
And C.CustomerID in (Select Customer from #tmpCustomer)
And IA.InvoiceID in (Select InvoiceNumber from #tmpInvoiceNum)

--Union
--Select InvoiceID,InvoiceDate,GSTFullDocID,AdditionalDiscount,"Supply Type" = 'Inward',"Sub Type" = 'Sales Return',"Doc Type" = 'Credit Note',
--"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
--"From_GSTIN" = Case When Isnull(IA.GSTIN,'') = '' Then 'URP' Else IA.GSTIN End,
--"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
--"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(IA.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
--"From_Place" = A.Area , "From_Pin Code" = C.Pincode ,"From_State" = (select Upper(StateName)  from statecode where StateID  = IA.ToStateCode) ,
--"Dispatch State" = (select upper(StateName)  from statecode where StateID  = IA.ToStateCode ),
--"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(((select organisationTitle from setup)),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
--"To_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
--"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
--   "To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
--"To_Place" = '',
--"To_Pin Code" = '',
--"To_State" = (select upper(StateName)  from statecode where StateID  = IA.FromStateCode ),
--"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = IA.FromStateCode)
--,"CSTaxType" = (Case When IA.FromStateCode = IA.ToStateCode Then 1 Else 2 End),
--"TotalInvoiceValue" = IA.NetValue, IA.GSTDOCID, IA.InvoiceType
--From InvoiceAbstract IA Join Customer C On C.CustomerID = IA.CustomerID Join Areas A On A.AreaID = C.AreaID
--Join Salesman SM On SM.SalesmanID = IA.SalesmanID
--Join #tmpSale TSM On TSM.Salesman_Name = SM.Salesman_Name
--Join Beat B On B.BeatID = IA.BeatID
--Join #tmpBeat TB On TB.BeatName = B.Description
--Where isnull(Status,0) & 128 = 0  and isnull(GSTFlag,0) = 1
--And dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE And InvoiceType In (4)
--And C.CustomerID in (Select Customer from #tmpCustomer)
--And IA.InvoiceID in (Select InvoiceNumber from #tmpInvoiceNum)
End

IF @SalesorSR <> 'D & D Delivery Challan'
Begin
--DDandInvoice Changes
Select Distinct
"InvoiceID" = DA.DandDInvID,
"Supply Type" ='Outward',
"Sub Type" ='Supply',
"Doc Type" = 'Tax Invoice',
"Doc No" = DA.GSTFullDocid,
"Doc Date" = DA.DandDInvDate,
"From_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select organisationTitle from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"From_GSTIN" = (select Case When Isnull(GSTIN,'') = '' Then 'URP' Else GSTIN End from Setup),
"From_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select BillingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE((select ShippingAddress from setup),'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"From_Place" = '',"From_Pin Code" = '',"From_State" = (select upper(StateName)  from statecode where StateID  = DA.FromStateCode ),
"Dispatch State" = (select upper(StateName)  from statecode where StateID  = DA.FromStateCode ),
"To_OtherPartyName" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.Company_Name,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'#',' '),',',' '),'&',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '), CHAR(40), ' '), CHAR(41), ' '), CHAR(92), ' '),' '),
"To_GSTIN" = Case When Isnull(DA.GSTIN,'') = '' Then 'URP' Else DA.GSTIN End,
"To_Address1" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.BillingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Address2" = IsNull(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C.ShippingAddress,'^',' '),'~',' '),'`',' '),'!',' '),'@',' '),'$',' '),'%',' '),'*',' '),'|',' '),':',' '),';',' '),'"',' '),'''',' '),'<',' '),'>',' '),'?',' '),'_',' '),'.',' '),'+',' '),'[',' '),']',' '),'{',' '),'}',' '),'=',' '),CHAR(10), ' '), CHAR(13), ' '), CHAR(9), ' '),' '),
"To_Place" =Isnull(A.Area,''),
"To_Pin Code" = Isnull(C.Pincode,''),
"To_State" = (select Upper(StateName)  from statecode where StateID  = DA.ToStateCode),
"Ship to State"  = (select Upper(StateName)  from statecode where StateID  = DA.ToStateCode),
"Product" = Isnull(I.ProductName,''),
"Description" = Isnull(I.ProductName,''),
--"DivName" = Isnull(DD.Division,''),
"DivName" = Isnull(IC2.Description,''),
"HSN" = Isnull(DD.HSN,''),
"Unit" = (
Case When @UOM = 'UOM1' then (Case When U1.Description = 'CFC' Then 'BOX' When U1.Description = 'EA' Then 'UNITS' When U1.Description = 'KAR' Then 'BOX' When U1.Description = 'KG' Then 'KILOGRAMS' When U1.Description = 'L' Then 'LITRES' When U1.Description = 'M_S' Then 'THOUSANDS' When U1.Description = 'PAC' Then 'PIECES' End)
When @UOM = 'UOM2' then (Case When U2.Description = 'CFC' Then 'BOX' When U2.Description = 'EA' Then 'UNITS' When U2.Description = 'KAR' Then 'BOX' When U2.Description = 'KG' Then 'KILOGRAMS' When U2.Description = 'L' Then 'LITRES' When U2.Description = 'M_S' Then 'THOUSANDS' When U2.Description = 'PAC' Then 'PIECES' End)
Else (Case When U.Description = 'CFC' Then 'BOX' When U.Description = 'EA' Then 'UNITS' When U.Description = 'KAR' Then 'BOX' When U.Description = 'KG' Then 'KILOGRAMS' When U.Description = 'L' Then 'LITRES' When U.Description = 'M_S' Then 'THOUSANDS' When U.Description = 'PAC' Then 'PIECES' End)
END
),
"Quantity" = (
Case When @UOM = 'UOM1' then SUM(DD.SaleQTY)/Case When IsNull(I.UOM1_Conversion, 1) = 0 Then 1 Else I.UOM1_Conversion End
When @UOM = 'UOM2' then SUM(DD.SaleQTY)/Case When IsNull(I.UOM2_Conversion, 1) = 0 Then 1 Else I.UOM2_Conversion End
Else SUM(DD.SaleQTY) / 1
End
),

"Assesable Value" = Sum(TaxableValue),
"Tax Rate" = cast(cast(Max(isnull(DD.SGSTRate,0)) as decimal(18,2))as varchar) + '+' + cast(cast(Max(isnull(DD.CGSTRate,0)) as decimal(18,2)) as varchar) + '+' + cast(cast(Max(isnull(DD.IGSTRate,0)) as decimal(18,2)) as varchar) + '+' + cast(cast(Max(isnull(DD.CESSRate,0)) as decimal(18,2)) as Varchar) + '+' + cast(cast(Max(isnull(DD.AddlCessRate,0)) as decimal(18,2)) as Varchar),
"CGST Amount" = Sum(isnull(DD.CGSTAmount,0)),
"SGST Amount" = Sum(isnull(DD.SGSTAmount,0)),
"IGST Amount" = Sum(isnull(DD.IGSTAmount,0)),
"Cess Amount" = Sum(isnull(DD.CESSAmount,0)) ,
"Cess Non Advol Amount" = Sum(isnull(DD.ADDLCESSAmount,0)) ,
"Others" = 0 ,
"Total Invoice Value" = Sum(DA.ClaimAmount),
"Trans Mode" = 'Road',
"Distance (Km)" = '',"Trans Name" = '',"Trans ID" = '',"Trans DocNo" = '',"Trans Date" = '', "Vehicle No" = '' ,"Vehicle Type" = 'Regular', DA.GSTDOCID
Into #DandDInvoiceDetails
from DandDInvAbstract DA
Inner Join DandDInvDetail DD on DA.DandDInvID = DD.DandDInvID
Inner Join Customer C On C.CustomerID = DA.CustomerID
Left outer Join Areas A On A.AreaID = C.AreaID
Inner Join Items I On   DD.SystemSKU = I.Product_Code
Inner Join ItemCategories IC4 ON IC4.CategoryID = I.CategoryID
Inner Join ItemCategories IC3 ON IC4.Parentid = IC3.CategoryID
Inner Join ItemCategories IC2 ON IC3.Parentid = IC2.CategoryID
Inner Join UOM U ON U.UOM = I.UOM
Inner Join UOM U1 ON U1.UOM = I.UOM1
Inner Join UOM U2 ON U2.UOM = I.UOM2
Where DA.DandDInvDate BETWEEN @FROMDATE AND @DandDTODATE
and Isnull(DnDFlag,0) = 1
and DA.DandDInvID in(Select InvoiceNumber From #tmpDandDInvoiceNum)
Group by DA.DandDInvID,DA.DandDInvID,DA.GSTFullDocID,DA.DandDInvDate,DA.FromStateCode,C.Company_Name,DA.GSTIN,C.BillingAddress,
C.ShippingAddress,A.Area,C.Pincode,DA.ToStateCode,I.ProductName,DD.Division,DD.HSN,U1.Description,U2.Description,U.Description,
I.UOM1_Conversion,I.UOM2_Conversion,IC2.Description, DA.GSTDOCID

End

IF @SalesorSR <> 'D & D Delivery Challan'
Begin
--Tax Details
Select  InvoiceID, Product_Code, SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.NetTaxAmount Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.NetTaxAmount Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.NetTaxAmount Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.NetTaxAmount Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.NetTaxAmount Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.NetTaxAmount Else 0 End),
ITC.Tax_Code
Into #TmpTaxDet
From GSTInvoiceTaxComponents ITC
Join TaxComponentDetail TCD On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where InvoiceID in(Select InvoiceID From #tmpInvoiceAbs)
Group By InvoiceID, Product_Code, SerialNo, ITC.Tax_Code

Select ID.InvoiceID,ID.Product_Code, ID.Serial Serial,Max(ID.SalePrice) SalePrice, Sum(ID.Quantity) Quantity,ID.UOM ,
Max(ID.TaxID) TaxID,MAX(ID.TaxCode) TaxCode,MAX(ID.TaxCode2) TaxCode2,
Max(ID.STPayable) STPayable, Max(ID.CSTPayable) CSTPayable,Max(ID.DiscountValue) DiscountValue, ID.HSNNumber,
IC2.Description DivName
,SGSTPer2=IsNUll((Select Tax_percentage From TaxComponents TC Inner Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where tcd.TaxComponent_desc = 'SGST' And Tax_Code = ID.TaxID And CSTaxType = IA.CSTaxType),0)
,UTGSTPer2=IsNUll((Select Tax_percentage From TaxComponents TC Inner Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where tcd.TaxComponent_desc = 'UTGST' And Tax_Code = ID.TaxID And CSTaxType = IA.CSTaxType),0)
,CGSTPer2=IsNUll((Select Tax_percentage From TaxComponents TC Inner Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where tcd.TaxComponent_desc = 'CGST' And Tax_Code = ID.TaxID And CSTaxType = IA.CSTaxType),0)
,IGSTPer2=IsNUll((Select Tax_percentage From TaxComponents TC Inner Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where tcd.TaxComponent_desc = 'IGST' And Tax_Code = ID.TaxID And CSTaxType = IA.CSTaxType),0)
,CESSPer2=IsNUll((Select Tax_percentage From TaxComponents TC Inner Join TaxComponentDetail TCD On TCD.TaxComponent_code  = TC.TaxComponent_code
Where tcd.TaxComponent_desc = 'CESS' And Tax_Code = ID.TaxID And CSTaxType = IA.CSTaxType),0)
Into #TmpInvoiceDetail
From InvoiceDetail ID
Inner Join #tmpInvoiceAbs IA On IA.InvoiceID = ID.InvoiceID
Inner Join Items I ON ID.Product_Code = I.Product_Code
Inner Join ItemCategories IC4 ON IC4.CategoryID  = I.CategoryID
Inner Join ItemCategories IC3 ON IC4.Parentid = IC3.CategoryID
Inner Join ItemCategories IC2 ON IC3.Parentid = IC2.CategoryID
--Where SalePrice > 0
Group By ID.InvoiceID,ID.Product_Code,ID.Serial, ID.UOM ,ID.HSNNumber,IC2.Description,ID.TaxID,IA.CSTaxType

Select ID.InvoiceID,ID.Product_Code,ID.DivName, ID.SalePrice, Sum(ID.Quantity) Quantity,ID.UOM ,
Sum(ID.STPayable) STPayable, Sum(ID.CSTPayable) CSTPayable,
Sum(ID.DiscountValue) DiscountValue, ID.HSNNumber,
SGSTPer= Case When Tmp.SerialNo Is Null Then Max(ID.SGSTPer2) Else Max(Tmp.SGSTPer) End ,
SGSTAmt= Sum(Tmp.SGSTAmt) ,
CGSTPer= Case When Tmp.SerialNo Is Null Then Max(ID.CGSTPer2) Else Max(Tmp.CGSTPer) End,
CGSTAmt= Sum(Tmp.CGSTAmt),
IGSTPer= Case When Tmp.SerialNo Is Null Then Max(ID.IGSTPer2) Else Max(Tmp.IGSTPer) End,
IGSTAmt= Sum(Tmp.IGSTAmt ) ,
UTGSTPer= Case When Tmp.SerialNo Is Null Then Max(ID.UTGSTPer2) Else Max(Tmp.UTGSTPer) End,
UTGSTAmt= Sum(Tmp.UTGSTAmt ),
CESSPer= Case When Tmp.SerialNo Is Null Then Max(ID.CESSPer2) Else Max(Tmp.CESSPer) End,
CESSAmt= Sum(Tmp.CESSAmt),
ADDLCESSPer= Max(Tmp.ADDLCESSPer),
ADDLCESSAmt= Sum(Tmp.ADDLCESSAmt) ,
ID.TaxID
Into #TmpInvoiceDet
From #TmpInvoiceDetail ID Left Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.UOM ,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID,ID.DivName,Tmp.SerialNo


Select IA.InvoiceID,[Supply Type],[Sub Type],[Doc Type],"Doc No" = Isnull(IA.GSTFullDocID,'') ,"Doc Date" = IA.InvoiceDate ,[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = Items.ProductName,"Description" = Items.ProductName,ID.DivName,
"HSN" = isnull(ID.HSNNumber,''),
"Unit" = (
Case When @UOM = 'UOM1' then (Case When U1.Description = 'CFC' Then 'BOX' When U1.Description = 'EA' Then 'UNITS' When U1.Description = 'KAR' Then 'BOX' When U1.Description = 'KG' Then 'KILOGRAMS' When U1.Description = 'L' Then 'LITRES' When U1.Description = 'M_S' Then 'THOUSANDS' When U1.Description = 'PAC' Then 'PIECES' End)
When @UOM = 'UOM2' then (Case When U2.Description = 'CFC' Then 'BOX' When U2.Description = 'EA' Then 'UNITS' When U2.Description = 'KAR' Then 'BOX' When U2.Description = 'KG' Then 'KILOGRAMS' When U2.Description = 'L' Then 'LITRES' When U2.Description = 'M_S' Then 'THOUSANDS' When U2.Description = 'PAC' Then 'PIECES' End)
Else (Case When U.Description = 'CFC' Then 'BOX' When U.Description = 'EA' Then 'UNITS' When U.Description = 'KAR' Then 'BOX' When U.Description = 'KG' Then 'KILOGRAMS' When U.Description = 'L' Then 'LITRES' When U.Description = 'M_S' Then 'THOUSANDS' When U.Description = 'PAC' Then 'PIECES' End)
END
),
"Quantity" = (
Case When @UOM = 'UOM1' then SUM(ID.Quantity)/Case When IsNull(Items.UOM1_Conversion, 1) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOM = 'UOM2' then SUM(ID.Quantity)/Case When IsNull(Items.UOM2_Conversion, 1) = 0 Then 1 Else Items.UOM2_Conversion End
Else SUM(ID.Quantity) / 1
End
),
"Assesable Value" = (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)))- (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),
"Tax Rate" = cast(Case When @UTGSTFlag = 1 Then cast(isnull(ID.UTGSTPer,0) as decimal(18,2)) Else cast(isnull(ID.SGSTPer,0) as decimal(18,2)) End as varchar)
+ '+' + cast(cast(isnull(ID.CGSTPer,0) as decimal(18,2)) as varchar)
+ '+' + cast(cast(isnull(ID.IGSTPer,0) as decimal(18,2)) as varchar)
+ '+' + cast(cast(isnull(ID.CESSPer,0) as decimal(18,2)) as Varchar)
+ '+' + cast(cast(isnull(ID.ADDLCESSPer,0) as decimal(18,2)) as Varchar),
"CGST Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Amount" = Sum(isnull(ID.CESSAmt,0)) ,
"Cess Non Advol Amount" = Sum(isnull(ID.ADDLCESSAmt,0)) ,
"Others" = 0 ,
"Total Invoice Value" = IA.TotalInvoiceValue,
"Trans Mode" = 'Road',
"Distance (Km)" = '',"Trans Name" = '',"Trans ID" = '',"Trans DocNo" = '',"Trans Date" = '', "Vehicle No" = '' ,"Vehicle Type" = 'Regular', IA.GSTDOCID, IA.InvoiceType
Into #TmpFinalRptData
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Items ON ID.Product_Code = Items.Product_Code
Inner Join UOM U ON U.UOM = Items.UOM
Inner Join UOM U1 ON U1.UOM = Items.UOM1
Inner Join UOM U2 ON U2.UOM = Items.UOM2
Group By IA.InvoiceID,IA.InvoiceDate, [Supply Type],[Sub Type],[Doc Type],IA.GSTFullDocID,
[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],[TotalInvoiceValue],
ID.Product_Code, Items.ProductName, isnull(ID.HSNNumber,''), ID.TaxID,ID.DivName,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer,ID.ADDLCESSPer,U.Description,U1.Description,U2.Description,Items.UOM1_Conversion,Items.UOM2_Conversion, IA.GSTDOCID, IA.InvoiceType

End

IF @SalesorSR = 'D & D Delivery Challan'
Begin

IF @SKUorHSN = 'SKU Wise'
Begin
Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1], [From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place], [To_Pin Code],[To_State],
[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[CESS Amount],
[Cess Non Advol Amount], [Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])

Select ID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[Product] ,[Description], "HSN" = Replace(HSN,' ',''), Unit,[Quantity],[Assesable Value],"Tax Rate (S+C+I+Cess+Cess Non Advol)"=[Tax Rate],[CGST Amount],[SGST Amount],
[IGST Amount],[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],
[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpDandDFinalRptData
Order By ClaimID
End
Else
Begin
Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1], [From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place], [To_Pin Code],[To_State],
[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[CESS Amount],
[Cess Non Advol Amount], [Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])

Select ID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = DivName,"Description" = DivName, "HSN" = Replace(HSN,' ',''), Unit, "Quantity" = Sum(Quantity),"Assesable Value" = Sum([Assesable Value]),
"Tax Rate (S+C+I+Cess+Cess Non Advol)"=[Tax Rate], "CGST Amount" = Sum([CGST Amount]),"SGST Amount" = Sum([SGST Amount]), "IGST Amount" = Sum([IGST Amount]),
"CESS Amount" = Sum([Cess Amount]),"Cess Non Advol Amount" = Sum([Cess Non Advol Amount]), "Others" = Sum([Others]),"Total Invoice Value" = [Total Invoice Value],
[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpDandDFinalRptData
Group By ID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State], [To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
DivName,[Tax Rate],HSN,Unit,[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type],[Total Invoice Value], ClaimID
Order By ClaimID
End
Drop Table #TmpDandDFinalRptData

End
Else IF @SalesorSR = 'Sales Return'
Begin

IF @SKUorHSN = 'SKU Wise'
Begin
Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])

Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[Product] ,[Description], "HSN" = Replace(HSN,' ',''), Unit ,[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[CESS Amount],
[Cess Non Advol Amount],[Others],[Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData Order By GSTDOCID
End
Else
Begin
Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])

Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = DivName,"Description" = DivName, "HSN" = Replace(HSN,' ',''), Unit, "Quantity" = Sum(Quantity),"Assesable Value" = Sum([Assesable Value]),[Tax Rate],
"CGST Amount" = Sum([CGST Amount]),"SGST Amount" = Sum([SGST Amount]), "IGST Amount" = Sum([IGST Amount]),"CESS Amount" = Sum([Cess Amount]),
"Cess Non Advol Amount" = Sum([Cess Non Advol Amount]),"Others"= Sum([Others]),"Total Invoice Value" = [Total Invoice Value], [Trans Mode],[Distance (Km)],
[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData
Group By InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State], [To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
DivName,[Tax Rate],HSN,Unit,[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type],[Total Invoice Value], GSTDOCID
Order By GSTDOCID
End
End
Else
Begin
IF @SKUorHSN = 'SKU Wise'
Begin

Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[Product] ,[Description], "HSN" = Replace(HSN,' ',''), Unit ,[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[CESS Amount],
[Cess Non Advol Amount],[Others],[Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData Where InvoiceType <> 4
Order By GSTDOCID

Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[Product] ,[Description], "HSN" = Replace(HSN,' ',''), Unit ,[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[CESS Amount],
[Cess Non Advol Amount],[Others],[Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData Where InvoiceType = 4
Order By GSTDOCID

Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select 	[Invoiceid],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[Product],[Description], "HSN" = Replace(HSN,' ',''), [Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],[Cess Amount],
[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type]
From #DandDInvoiceDetails
Order By GSTDocID
End
Else
Begin
Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = DivName,"Description" = DivName, "HSN" = Replace(HSN,' ',''), Unit , "Quantity" = Sum(Quantity),
"Assesable Value" = Sum([Assesable Value]),[Tax Rate],"CGST Amount" = Sum([CGST Amount]),"SGST Amount" = Sum([SGST Amount]),
"IGST Amount" = Sum([IGST Amount]),"CESS Amount" = Sum([Cess Amount]),"Cess Non Advol Amount" = Sum([Cess Non Advol Amount]),"Others"= Sum([Others]),
"Total Invoice Value" = [Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData Where InvoiceType <> 4
Group By InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State], [To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
DivName,[Tax Rate],HSN,Unit,[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type],[Total Invoice Value], InvoiceType, GSTDOCID
Order By GSTDOCID

Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = DivName,"Description" = DivName, "HSN" = Replace(HSN,' ',''), Unit , "Quantity" = Sum(Quantity),
"Assesable Value" = Sum([Assesable Value]),[Tax Rate],"CGST Amount" = Sum([CGST Amount]),"SGST Amount" = Sum([SGST Amount]),
"IGST Amount" = Sum([IGST Amount]),"CESS Amount" = Sum([Cess Amount]),"Cess Non Advol Amount" = Sum([Cess Non Advol Amount]),"Others"= Sum([Others]),
"Total Invoice Value" = [Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type]
From #TmpFinalRptData Where InvoiceType = 4
Group By InvoiceID,[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State], [To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
DivName,[Tax Rate],HSN,Unit,[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo] ,[Trans Date], [Vehicle No],[Vehicle Type],[Total Invoice Value], InvoiceType, GSTDOCID
Order By InvoiceType, GSTDOCID

Insert Into #TempEwaybill ([InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],[Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type])
Select 	[Invoiceid],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],
[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
"Product" = DivName, "Description" = DivName,  --[Product],[Description],
"HSN" = Replace(HSN,' ',''),  [Unit],
"Quantity" = Sum([Quantity]),"Assesable Value" = Sum([Assesable Value]),[Tax Rate],"CGST Amount" = Sum([CGST Amount]),"SGST Amount" = Sum([SGST Amount]),
"IGST Amount" = Sum([IGST Amount]),"CESS Amount" = Sum([Cess Amount]),"Cess Non Advol Amount" = Sum([Cess Non Advol Amount]),"Others"= Sum([Others]),[Total Invoice Value],
[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type]
From #DandDInvoiceDetails
Group by [Invoiceid],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],[From_OtherPartyName],[From_GSTIN],[From_Address1],[From_Address2],[From_Place], DivName,
[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],[To_Pin Code],[To_State],[Ship to State],
[HSN],[Unit],[Tax Rate],[Total Invoice Value], [Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type], GSTDocID
Order By GSTDocID
End
End

Select [InvoiceID],[Supply Type],[Sub Type],[Doc Type],[Doc No],[Doc Date],"Transaction type"='Regular',[From_OtherPartyName],[From_GSTIN],[From_Address1],
[From_Address2],[From_Place],[From_Pin Code],[From_State],[Dispatch State],[To_OtherPartyName],[To_GSTIN],[To_Address1],[To_Address2],[To_Place],
[To_Pin Code],[To_State],[Ship to State],[Product],[Description],[HSN],[Unit],[Quantity],[Assesable Value],"Tax Rate (S+C+I+Cess+Cess Non Advol)" = [Tax Rate],[CGST Amount],[SGST Amount],[IGST Amount],
[CESS Amount],[Cess Non Advol Amount],[Others],[Total Invoice Value],[Trans Mode],[Distance (Km)],[Trans Name],[Trans ID],[Trans DocNo],[Trans Date],[Vehicle No],[Vehicle Type]
from #TempEwaybill
Order by [Ids]

Drop Table #TmpInvoiceAbs
Drop Table #tmpBeat
Drop Table #tmpSale
Drop Table #tmpCustomer
Drop Table #tmpInvoiceNum
Drop Table #tmpDandDInvoiceNum
Drop Table #TempEwaybill

IF @SalesorSR <> 'D & D Delivery Challan'
Begin
Drop Table #TmpInvoiceDet
Drop Table #TmpTaxDet
Drop Table #TmpFinalRptData
Drop Table #TmpInvoiceDetail
Drop Table #DandDInvoiceDetails
End

End
