Create Procedure Sp_CreateSOFromHandheld @SalesmanID int,@LogID int
AS
BEGIN
BEGIN TRY
--			BEGIN TRAN

/*Temporary Tables to improve performance Starts */
select OH.* into #tmpOrder_Header from Order_Header OH
Where OH.[Processed] = 0
And OH.SalesmanID=@SalesmanID

Select OD.* into #tmpOrder_details from Order_details OD,#tmpOrder_Header OH
where OH.OrderNumber=OD.OrderNumber

--Delete From #tmpOrder_Header Where OrderNumber Not In (Select Distinct OrderNumber From #tmpOrder_details)

Create Table #tmpGroupID (Product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)
insert into #tmpGroupID(Product_code,GroupID)
Select distinct I.Product_Code,dbo.sp_han_GetCategoryGroup(I.CategoryID) from #tmpOrder_details OD,Items I
Where OD.Product_Code=I.Product_Code
/*Temporary Tables to improve performance Ends */

declare @gst_taxid  int, @gst_taxtype int , @gst_taxamount  decimal(18,2) --GST_Changes

Create Table #Prefix(PrefixName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
insert into #Prefix(PrefixName)
Exec sp_get_VoucherPrefix 'SALE CONFIRMATION'

Declare @SOPrefix nvarchar(255)
Select top 1 @SOPrefix=PrefixName from #Prefix

Declare @VoucherPrefix nvarchar(255)
Set dateformat dmy
Declare @DayCloseDate Datetime
Select @DayCloseDate=dbo.StripDateFromTime(LastInventoryUpload) from Setup

Create Table #FreeDetailFinal([ORDERNUMBER] nvarchar(2000),[FreeProductCode] nvarchar(2000),[Fqty] decimal(18,6),[UOM_ID] int,[UOM_Desc] nvarchar(2000),[Item_Code] nvarchar(2000),[Item_UOM] int,
[Item_UOM1] int,[Item_UOM2] int,[Item_TrackPKD] int,[Item_CategoryID] int,[Item_TrackInventory] int,[Item_PriceOption] int,[Batch_Number] nvarchar(2000),[Batch_Itemexists] nvarchar(2000),[Item_Converter] decimal(18,6),
[Discount] decimal(18,6),[DiscountValue] decimal(18,6),[Det_ID] int,[Rejected] int,
SalePrice decimal(18,6),Qty decimal(18,6),Disc decimal(18,6),LST decimal(18,6),CST decimal(18,6),TaxSuffPer decimal(18,6),UOMPrice decimal(18,6),ApplicableOn int,PartOff decimal(18,6),TSApplicableOn decimal(18,6),TSPartOff decimal(18,6),ECP decimal(18,6))

Create Table #OrdDetailFinal([ORDERNUMBER] nvarchar(2000),[ITEMID] nvarchar(2000),[ORDEREDQTY] decimal(18,6),[Order_UOM_Desc] nvarchar(2000),[UOM_ID] int,[UOM_Desc] nvarchar(2000),[Item_Code] nvarchar(2000),[Item_UOM] int,
[Item_UOM1] int,[Item_UOM2] int,[Item_PurchasePrice] decimal(18,6),[Item_Saleprice] decimal(18,6),[Item_SaleTax] decimal(18,6),[Item_MRP] decimal(18,6),[Item_CompanyPrice] decimal(18,6),[Item_PTS] decimal(18,6),
[Item_PTR] decimal(18,6),[Item_ECP] decimal(18,6),[Item_TaxSuffered] decimal(18,6),[Item_Vat] int,[Item_CollectTaxSuffered] int,[Item_Track_Batches] int,[Item_TrackPKD] int,[Item_CategoryID] int,[Item_TrackInventory] int,
[Item_PriceOption] int,[Batch_Number] nvarchar(2000),[Batch_SalePrice] nvarchar(2000),[Batch_ecp] nvarchar(2000),[Batch_PTR] nvarchar(2000),[Batch_Company_Price] nvarchar(2000),[Batch_PTS] nvarchar(2000),[Batch_TaxSuffered] nvarchar(2000),
[Batch_ApplicableOn] nvarchar(2000),[Batch_Partofpercentage] nvarchar(2000),[Batch_Itemexists] nvarchar(2000),[SaletaxPer] decimal(18,6),[SaleTaxApplicableOn] int,[SaleTaxPartOff] decimal(18,6),[TS_taxPer] decimal(18,6),
[TS_TaxApplicableOn] int,[TS_TaxPartOff] decimal(18,6),[Item_Converter] decimal(18,6),[Flag] int,[ErrFlag] int,[Discount%] decimal(18,6),[DiscountVALUE] decimal(18,6),[Det_ID] int,[Rejected] int,
SalePrice decimal(18,6),Qty decimal(18,6),Disc decimal(18,6),LST decimal(18,6),CST decimal(18,6),TaxSuffPer decimal(18,6),UOMPrice decimal(18,6),ApplicableOn int,PartOff decimal(18,6),TSApplicableOn decimal(18,6),TSPartOff decimal(18,6),ECP decimal(18,6), SplitCount int)


--Create Table #tmpSPLITSO(OrderNUMBER nvarchar(100), Order_DATE Datetime, Delivery_Date Datetime, Order_SALESMANID int,
--	Order_BeatID int, Order_CustID nvarchar(100), CompanyID nvarchar(100), CreationDate Datetime, Processed int,
--	Order_VanOrder nvarchar(100), Order_VanLoadSlipNumber int, C_Customerid nvarchar(100), C_Customername nvarchar(100),
--	C_CreditTerm int, S_SalesmanID int, C_Locality int, C_BillingAddress nvarchar(100),C_ShippingAddress nvarchar(100),
--	C_CreditLimit int, C_CustomerCategory nvarchar(100), Count int, Payment_Type int, Discount_Amt Decimal(18,6),
--	Discount_Per Decimal(18,6), OrderRefNumber nvarchar(100), SOValue Decimal(18, 2), CreditTerm int, VatTaxAmount Decimal(18,6),
--	CGGroup nvarchar(100)
--)

Create Table #tmpSPLITSO(OrderNUMBER nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Order_DATE Datetime, Delivery_Date Datetime, Order_SALESMANID int,
Order_BeatID int, Order_CustID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, C_BillingAddress nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
C_ShippingAddress nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SOValue Decimal(18, 6), CreditTerm int, VatTaxAmount Decimal(18,6),
OrderRefNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CGGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SplitCount int, GrpSalesmanID int, OrderType Int,OrderTypeMap nVarchar(100))

/* Inserting Order Header data into a Temp Table*/
Select o.[OrderNUMBER],
o.[Order_DATE],
o.[DELIVERY_DATE],
o.[SALESMANID] 'Order_SALESMANID',
(Case when Isnull(o.[BeatID], '') = '' or o.[BeatID] = 0 then
(
Select top 1 BS.BeatID from Beat_SalesMan BS
Inner Join Beat B On B.BeatID = BS.BeatID and B.Active = 1
where BS.SalesmanID = o.[SALESMANID] and BS.CustomerID = o.[OUTLETID]
)
else o.[BeatID] end) 'Order_BeatID',
o.[OUTLETID] 'Order_CustID',
o.[PROFITCENTER] 'CompanyID',
o.[CreationDate],
o.[Processed],
Isnull(o.[VanOrder],'') 'Order_VanOrder',
isnull(o.[VanLoadingSlipNumber],0) 'Order_VanLoadSlipNumber',
Isnull(c.Customerid, '') 'C_Customerid',
Isnull(c.Company_name, '') 'C_Customername',
case when  isnull (c.CreditTerm,0) <= 0   then
isnull (CT.CreditID,0)
else
isnull (c.CreditTerm ,0)
end 'C_CreditTerm' ,
Isnull(s.SalesmanID, 0) 'S_SalesmanID',
IsNull(c.Locality, 1) 'C_Locality',
c.BillingAddress 'C_BillingAddress',
c.ShippingAddress 'C_ShippingAddress',
Isnull(c.CreditLimit, 0) 'C_CreditLimit',
c.CustomerCategory 'C_CustomerCategory',
(Select Count(*) From #tmpOrder_Header u Where u.OrderNUMBER = o.OrderNUMBER and u.Order_DATE>@DayCloseDate) 'Count',
o.PaymentType 'Payment_Type',
o.DiscountAmt 'Discount_Amt',
o.DiscountPer 'Discount_Per' ,
(Case When OrderNUMBER  Like'ORD%' Then OrderNUMBER Else (Case isNull(o.OrderRefNumber,'') When '' Then  OrderNUMBER Else o.OrderRefNumber End) End) 'OrderRefNumber',
cast(0 as decimal(18,6)) as  [SOValue],
cast(0 as decimal(18,6)) as [CreditTerm],
cast(0 as decimal(18,6)) as [VatTaxAmount],
cast('' as nvarchar(2000)) as [CGGroup]
,Rejected = Cast(0 as Int)
,o.OrderType
,(Select Description
from VirtualOrders_Master M
Where M.ID = O.OrderType  ) 'OrderTypeMap'
into #tmpSO
From #tmpOrder_Header o
left outer join Customer c On c.CustomerID = o.[OUTLETID]
left outer join (select top 1 creditid, active from creditterm where active = 1 ) CT On 1 = 1 and CT.Active = 1
left outer join Salesman s On Cast(s.SalesmanID as nvarchar)= o.[SALESMANID]
Where o.[Processed] = 0
And O.SalesmanID=@SalesmanID
Order by o.CreationDate


--Alter Table #tmpSO Add Rejected Int

Declare @OrdNumber nvarchar(200)
Declare @DocDate Datetime
Declare @SalesManName nvarchar(2000)
Declare @CustomerName nvarchar(2000)
Declare @BeatName nvarchar(2000)
Declare @C_CustomerCategory int
Declare @C_Locality int

Declare @NextFlag int

Create Table #DaycloseConfig(InvConfigValue int,FAConfigValue int)
Insert into #DaycloseConfig(InvConfigValue,FAConfigValue)
exec mERP_GetCloseDay_Config

Declare @InvConfigValue int
Declare @Error Nvarchar(2000)
Declare @ErrOrdNumber nvarchar(255)
Declare @ErrSalesmanID int
/* Duplicate Orders*/

/* Error Starts */
Declare Error Cursor For Select OrderNUMBER from #tmpSO where [COUNT]>1
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' + cast(@ErrOrdNumber as nvarchar(200))+ ' is not unique in staging table [ORDER_HEADER].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */


/* BackDated SO Validation*/
Select Top 1 @InvConfigValue=InvConfigValue from #DaycloseConfig
Set @Error=''
/* Error Starts Check1*/
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where dbo.fn_HasAdminPassword(#tmpSO.OrderNUMBER,dbo.StripDateFromTime(#tmpSO.Order_date),@InvConfigValue)  <> ''
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Select @Error=dbo.fn_HasAdminPassword(#tmpSO.OrderNUMBER,dbo.StripDateFromTime(#tmpSO.Order_date),@InvConfigValue)
from #tmpSO where OrderNumber=@ErrOrdNumber

Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */


/*Customer ID Validation*/
/* Error Starts */
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where isnull(Order_CustID,'')=''
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number '+@ErrOrdNumber+' has empty CustomerID.'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */


/*Customer ID Validation*/
/* Error Starts */
Declare @ErrCustID nvarchar(255)
Declare Error Cursor For Select  OrderNUMBER,Order_CustID from #tmpSO where isnull(Order_CustID,'')<>isnull(C_Customerid,'')
Open Error
Fetch from Error into @ErrOrdNumber,@ErrCustID
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' +@ErrOrdNumber+' has an invalid CustomerID [' + @ErrCustID+ '].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber,@ErrCustID
END
Close Error
Deallocate Error
/* Error Ends */



/*Payment Type Validation*/
/* Error Starts */
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where isnull(Payment_Type,'') not in(0,1)
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Declare @PayType int
Select @PayType=isnull(Payment_Type,'') from #tmpSO where OrderNumber=@ErrOrdNumber
Set @Error= 'Order number ' +@ErrOrdNumber+ ' has Invalid Payment Type [' + cast(@PayType as nvarchar(10)) + '].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */

/* Salesman ID Validation */
/* Error Starts */
Declare @ErrOrder_SALESMANID nvarchar(255)
Declare Error Cursor For Select  OrderNUMBER,Order_SALESMANID from #tmpSO where isnull(Order_SALESMANID,'')  <>'' and  ISNUMERIC(Order_SALESMANID) =0
Open Error
Fetch from Error into @ErrOrdNumber,@ErrOrder_SALESMANID
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' + @ErrOrdNumber + ' has an invalid SalesManID [' + @ErrOrder_SALESMANID + '].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber,@ErrOrder_SALESMANID
END
Close Error
Deallocate Error
/* Error Ends */

/* Salesman ID Validation */
/* Error Starts */
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where isnull(Order_SALESMANID,'')  =''
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' + @ErrOrdNumber + ' has empty SalesManID.'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */

/* Order type Validation */
/* Error Starts */
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where isnull(OrderTypeMap,'')  = '' And OrderType <> 0
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' + @ErrOrdNumber + ' has an Invalid Order Type.'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */


/* Salesman ID Validation */
/* Error Starts */
Declare Error Cursor For Select  OrderNUMBER from #tmpSO where isnull(Order_SALESMANID,'')  <> isnull(S_SalesmanID,'')
Open Error
Fetch from Error into @ErrOrdNumber
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' +@ErrOrdNumber+' has an invalid SalesmanID [' + Cast(@SalesmanID As nVarChar(50))+ '].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber
END
Close Error
Deallocate Error
/* Error Ends */

/* Beat And Customer Validation */
/* Error Starts */
Declare @ErrBeatID nvarchar(255)
Declare @ErrCustomerID nvarchar(255)
Declare Error Cursor For Select OrderNUMBER,cast(Order_BeatID as nvarchar(255)),Order_CustId from #tmpSO where cast(isnull(Order_BeatID,0) as nvarchar(255)) + cast(isnull(Order_CustId,0) as nvarchar(255))
not in (Select Distinct cast(BeatID as nvarchar(255))+ cast(CustomerID as nvarchar(255))  from Beat_SalesMan)
Open Error
Fetch from Error into @ErrOrdNumber,@ErrBeatID,@ErrCustomerID
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' +@ErrOrdNumber+' has an invalid Beat ['+@ErrBeatID+ ']and Customer ['+@ErrCustomerID+ '] Mapping'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber,@ErrBeatID,@ErrCustomerID
END
Close Error
Deallocate Error
/* Error Ends */

/*  Salesman ID defined to Beat Validation */
/* Error Starts */
Declare Error Cursor For Select OrderNUMBER,cast(Order_BeatID as nvarchar(255)),Order_CustId from #tmpSO where cast(isnull(Order_BeatID,0) as nvarchar(255)) + cast(isnull(Order_CustId,0) as nvarchar(255))
not in (Select Distinct cast(BeatID as nvarchar(255))+ cast(CustomerID as nvarchar(255)) From Beat_SalesMan Where SalesmanID = @SalesmanID)
Open Error
Fetch from Error into @ErrOrdNumber,@ErrBeatID,@ErrCustomerID
While @@FETCH_STATUS =0
BEGIN
BEGIN TRAN
Set @Error= 'Order number ' +@ErrOrdNumber+'  - SalesmanID ['+Cast(@SalesmanID As nVarChar(50))+ '] is not defined to Beat ['+@ErrBeatID+ '].'
Delete from #tmpSO where OrderNumber=@ErrOrdNumber
exec sp_han_InsertErrorlog @ErrOrdNumber,1,'Information','Aborted',@Error,@SalesmanID
exec sp_han_updatesc @ErrOrdNumber,2
COMMIT TRAN
Fetch Next from Error into @ErrOrdNumber,@ErrBeatID,@ErrCustomerID
END
Close Error
Deallocate Error
/*  Salesman ID defined to Beat Validation */
/* Error Ends */

Declare Orders Cursor For Select Ordernumber,Order_date,C_CustomerCategory,C_Locality from #tmpSO order by Order_date
Open Orders
Fetch from Orders into @OrdNumber,@DocDate,@C_CustomerCategory,@C_Locality
While @@FETCH_STATUS = 0
BEGIN

/* Category Group and UOM Validation*/
Create Table #OrdDetails (PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
I_PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, I_UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, I_Group nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

--Insert into #OrdDetails(PC,UOM,I_PC,I_UOM,I_Group)
--exec sp_han_ValidateOrderDetails @OrdNumber
Create Table #TempValid (PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
IPC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
IUOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
GroupID integer,
Flag tinyint)
Insert into #TempValid
Select OD.Product_Code, Items.Product_Code, OD.UOMID, UOM.UOM,
--Isnull(dbo.sp_han_GetCategoryGroup(Items.CategoryID), 0) GroupID
Isnull(T.GroupID, 0) GroupID, 1
from #tmpOrder_details OD
Join #tmpGroupID T On T.Product_code=OD.Product_Code
Left Outer Join Items On OD.Product_Code = Items.Product_Code
Left Outer Join UOM On OD.UOMID = UOM.UOM
Where OD.OrderNumber = @OrdNumber

Insert into #OrdDetails(PC,UOM,I_PC,I_UOM,I_Group)
Select PC, UOM, (Case when IPC is null then 'Invalid Item code ' + Isnull(PC, '') else '' end) I_PC,
(Case when IUOM is null then 'Invalid UOM For the Item Code ' + Isnull(PC, '') else '' end) I_UOM,
(Case When GroupID = 0 then 'Invalid Product Category Group' + Isnull(PC, '') else '' end) I_Group
from #TempValid
Where IPC is null or IUOM is null or GroupID = 0

Drop	Table #TempValid

Declare @Status nvarchar(100)
If exists(select 'x' from #OrdDetails where isnull(I_PC,'')<>'')
BEGIN
Select Top 1 @Status=I_PC from #OrdDetails where isnull(I_PC,'')<>''
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' '+@Status
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Drop Table #OrdDetails
Goto NextOrder1
END

If exists(select 'x' from #OrdDetails where isnull(I_UOM,'')<>'')
BEGIN
Select Top 1 @Status=I_UOM from #OrdDetails where isnull(I_UOM,'')<>''
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' '+@Status
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Drop Table #OrdDetails
Goto NextOrder1
END

If exists(select 'x' from #OrdDetails where isnull(I_Group,'')<>'')
BEGIN
Select Top 1 @Status=I_Group from #OrdDetails where isnull(I_Group,'')<>''
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' '+@Status
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Drop Table #OrdDetails
Goto NextOrder1
END
Drop Table #OrdDetails


--Declare @CusBalance Decimal(18,6)
Declare @CustID nvarchar(255)
Select @CustID= Order_CustID from #tmpSO where OrderNumber=@OrdNumber

--GST_Changes starts here
if Exists (select 'x' From customer cu(nolock)
Join setup st(nolock) on cu.BillingStateID = st.BillingStateID where cu.CustomerID = @custid)
select @gst_taxtype = 1
else
select @gst_taxtype = 2
--GST_Changes ends here

/*
Create Table #CusBalance(Balance decimal(18,6))

--Insert into #CusBalance(Balance)
--Exec sp_get_Customer_OutStanding_Balance @CustID

declare @Balance as Decimal(18,6)
declare @CLBalance as Decimal(18,6)
declare @CRBalance as Decimal(18,6)
declare @DBBalance as Decimal(18,6)
declare @INVBalance as Decimal(18,6)
declare @SRBalance as Decimal(18,6)

select @CLBalance = sum(Balance) from Collections
where CustomerID = @CustID and Balance > 0

select @CRBalance = sum(Balance) from CreditNote
where CustomerID = @CustID and Balance > 0

select @DBBalance = sum(Balance) from DebitNote
where CustomerID = @CustID and Balance > 0

select @INVBalance = sum(Balance) from InvoiceAbstract
where CustomerID = @CustID and Balance > 0 and InvoiceType in (1, 3) and
Status & 128 = 0


select @SRBalance = sum(Balance) from InvoiceAbstract
where CustomerID = @CustID and Balance > 0 and Status & 128 = 0 and
InvoiceType = 4

set @Balance = isnull(@CLBalance, 0) + isnull(@CRBalance, 0) + isnull(@SRBalance, 0) -
isnull(@DBBalance, 0) - isnull(@INVBalance, 0)

Insert into #CusBalance(Balance)
select @Balance

Select Top 1 @CusBalance=isnull(Balance,0) from #CusBalance

Drop Table #CusBalance
*/

/* Order Detail Validation*/
Create Table #SplitOrders (OrderNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CreditTerm int,CreditLimit decimal(20,6),SalesmanID int)
--Insert into #SplitOrders (OrderNumber,CreditTerm,CreditLimit,SalesmanID)
--exec sp_han_SplitOrders @OrdNumber,@CustID,@SalesmanID
declare @GroupName nVarchar(100)
declare @CustName  nVarchar(300)
declare @msg nvarchar(500)

If Exists(select * from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid Where DSD.SalesmanID = @SalesManID and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1 and TDSCGM.GroupID = 0 and
(select Count(*) from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid Where DSD.SalesmanID = @SalesManID and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1) = 1)
Begin
Insert into #SplitOrders (OrderNumber,CreditTerm,CreditLimit,SalesmanID)
-- Salesman handle all category
Select IsNull(@OrdNumber,''), 0 'CreditTerm', 0 'CreditLimit',0 'SalesmanID'
End
Else
Begin
-- Salesman handle Specific category
create table #TmpSalesmanCat (OrderNumber nVarchar(100),CreditTermDays int,CreditLimit decimal(20,6),SalesManID Int,GroupName nVarchar(100),GroupID int)
insert into #TmpSalesmanCat
Select distinct  IsNull(OD.OrderNumber,'') 'OrderNumber'
--min(Isnull(CCL.CreditTermDays, 0)) 'CreditTerm',
--min(IsNull(CCL.CreditLimit,0)) 'CreditLimit'
,(Select min(IsNull(CCL.CreditTermDays,0)) From CustomerCreditLimit CCL Where CCL.CustomerID= @CustId ) 'CreditTerm'
,(Select min(IsNull(CCL.CreditLimit,0)) From CustomerCreditLimit CCL Where CCL.CustomerID= @CustId ) 'CreditLimit'
, case when (@SalesManID in (select DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0) and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1)) then @SalesManID
else (
select top 1 DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM
on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0) and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1
inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@CustId order by DSD.Salesmanid) end 'SalesmanID'
,GD.GroupName
,GD.GroupId
From #tmpOrder_details OD
Inner Join #tmpOrder_Header OH On Convert(nVarchar,OD.OrderNumber) = @OrdNumber
And OH.OrderNumber = OD.OrderNumber And OH.Processed = 0
Inner Join Items ITM On OD.Product_Code = ITM.Product_Code
Inner Join #tmpGroupID T On T.Product_code=ITM.Product_code
Inner Join ProductCategoryGroupAbstract GD ON GD.GroupID= T.GroupID
--Inner Join ProductCategoryGroupAbstract GD On GD.GroupId = Isnull(dbo.sp_han_GetCategoryGroup(ITM.CategoryId), 0)
Left outer Join CustomerCreditLimit CCL On CCL.GroupID = GD.GroupId and CCL.CustomerID = @CustId
group by OD.OrderNumber, GD.GroupID, SalesmanID
--, CCL.CreditTermDays, CCL.CreditLimit
,GD.GroupName,GD.GroupId
end

if exists(select * from #TmpSalesmanCat where SalesManID is null)
begin
set @GroupName=''
set @CustName=''
select @GroupName=@GroupName+dbo.fn_han_Get_GroupItems(@OrdNumber,GroupID)+',' from #TmpSalesmanCat where SalesManID is null
select @GroupName= left(@GroupName,len(@GroupName)-1)
select @CustName=isnull(Company_Name,'') from customer where customerid= @CustId
set @msg='No Salesman attached to the Category Group(s) '+ @GroupName+' for Customer '+@CustId+' - '+@CustName
exec sp_han_InsertErrorlog @OrdNumber,1,'Error','Aborted' ,@msg,@SalesmanID
end
Insert into #SplitOrders (OrderNumber,CreditTerm,CreditLimit,SalesmanID)
select distinct  OrderNumber 'OrderNumber',
CreditTermDays 'CreditTerm',CreditLimit 'CreditLimit',isnull(SalesManID,0) 'SalesmanID' from #TmpSalesmanCat

drop table #TmpSalesmanCat

If (select count(*) from #SplitOrders)=0
BEGIN

BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' has no detail information.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
--Drop Table #SplitOrders
Goto NextOrder
END

Declare @SplitCount int
Declare @DetSalesmanID int
Declare @DetCreditTerm Int
Declare @tmpDSID int
Set @tmpDSID = 0
Set @SplitCount = 0
Select @tmpDSID=SalesmanID from  #SplitOrders where isnull(SalesmanID, 0) <> 0
--Select @tmpDSID
--Delete from #SplitOrders where salesmanID <> @tmpDSID
Declare Split Cursor For Select SalesmanID,CreditTerm from #SplitOrders where isnull(SalesmanID, 0) <> 0
Open Split
Fetch from Split into @DetSalesmanID,@DetCreditTerm
While @@Fetch_status=0
BEGIN
update #tmpSO set CreditTerm=case when @DetCreditTerm > 0 then @DetCreditTerm else C_CreditTerm end where OrderNumber=@OrdNumber

Set @SplitCount = @SplitCount + 1
--					if (isnull(@DetSalesmanID,0)=0)
--					BEGIN
--						Goto NextSplit
--					END
/*Detail Part starts*/
Declare @Locality As Int
Declare @GroupID as nvarchar(200)
Select @Locality = Locality From Customer
Where CustomerID = (Select Top 1 OutletID From #tmpOrder_Header Where ORDERNUMBER = @OrdNumber)
Set @Locality = IsNull(@Locality, 1)

--select @GroupID=dbo.fn_han_Get_ItemGroup(@OrdNumber,@DetSalesmanID)
Declare @FN_OrderNumber as nVarchar(50)
Declare @FN_grpSalesmanID as Int

Set @tmpDSID = @DetSalesmanID
Set @FN_grpSalesmanID = @tmpDSID
Declare @FN_GroupID as nvarchar(1000)
declare @FN_OrdSalesManID Int,@FN_CustID nvarchar(30)
set @FN_GroupID=''
Select @FN_OrdSalesManID=SalesManID,@FN_CustID=OutletID from #tmpOrder_Header where OrderNumber= @OrdNumber

Create Table #FN_TmpGrpID (GroupID int,SalesmanID int)
insert into #FN_TmpGrpID
Select distinct IsNull(GD.GroupID,0) 'GroupID',
case when (@FN_OrdSalesManID in (select DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1 and TDSCGM.GroupId=IsNull(GD.GroupID,0))) then @FN_OrdSalesManID
else (select top 1 DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0) and TDSCGM.Active=1 And  DSD.DSTypeCtlPos=1
inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@FN_CustID order by DSD.Salesmanid) end 'SalesmanID'
From #tmpOrder_details OD
Inner Join #tmpOrder_Header OH On Convert(nVarchar,OD.OrderNumber) = @OrdNumber
And OH.OrderNumber = OD.OrderNumber
Inner Join Items ITM On OD.Product_Code = ITM.Product_Code
Inner Join  #tmpGroupID Tmp On tmp.Product_code=ITM.Product_code
Inner Join ProductCategoryGroupAbstract GD  ON GD.GroupID =  Tmp.GroupID
Left outer Join CustomerCreditLimit CCL On CCL.GroupID = GD.GroupId and CCL.CustomerID = @FN_CustID
group by OD.OrderNumber, GD.GroupID, CCL.CreditTermDays, CCL.CreditLimit
order by SalesmanID,GroupID
select  @FN_GroupID=@FN_GroupID+cast(GroupID as nvarchar(30))+',' from #FN_TmpGrpID where SalesmanID=@FN_grpSalesmanID

Delete From #FN_TmpGrpID
Drop Table #FN_TmpGrpID
if(isnull(@FN_GroupID,'')='')
Set @FN_GroupID=''
Else
set @FN_GroupID=left(@FN_GroupID,len(@FN_GroupID)-1)

Set @GroupID=@FN_GroupID

Create Table #Products(Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into #Products(Product_Code)
Select Product_Code from dbo.sp_Get_Items_ITC(@GroupID)

--Temp table to accumulate ordered And scheme item
Create Table #Ord_Det (OrderNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
, ItemID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
, OrderedQty Decimal(18, 6)
, UOM nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
, O_ItemID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
, O_OrderedQty Decimal(18, 6)
, O_UOM nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
, Flag Integer, ErrFlag Integer
, [Det_ID] integer,Serial int)

--Dumb Details of Ordered item
Insert Into #Ord_Det
Select I_OD.OrderNumber
, I_OD.Product_Code 'ItemID', I_OD.OrderedQty 'OrderedQty',I_OD.UOMID 'UOM'
, I_OD.Product_Code 'O_ItemID', I_OD.OrderedQty 'O_OrderedQty', I_OD.UOMID 'O_UOM'
, 1 'Flag', 0 'ErrFlag' -- Function to validate Scheme Details
, I_OD.Order_Detail_ID,I_OD.Serial
From #tmpOrder_details I_OD Where I_OD.[ORDERNUMBER] = @OrdNumber

--Retrieve info
Select od.[ORDERNUMBER], od.[ITEMID], od.[ORDEREDQTY] -- od.[UOM] 'Order_UOM_Desc'
, u.[Description] 'Order_UOM_Desc'
,IsNull(u.[UOM], 0) 'UOM_ID', IsNull(u.[Description], '') 'UOM_Desc'
,IsNull(i.Product_Code, '') 'Item_Code'
,IsNull(i.UOM, 0) 'Item_UOM'
,IsNull(i.UOM1, 0) 'Item_UOM1'
,IsNull(i.UOM2, 0) 'Item_UOM2'
,IsNull(i.Purchase_Price, 0) 'Item_PurchasePrice'
,IsNull(i.Sale_Price, 0) 'Item_Saleprice'
,IsNull(i.Sale_Tax, 0) 'Item_SaleTax'
,IsNull(i.MRP, 0) 'Item_MRP'
,IsNull(i.Company_Price, 0) 'Item_CompanyPrice'
,IsNull(i.PTS, 0) 'Item_PTS'
,IsNull(i.PTR, 0) 'Item_PTR'
,IsNull(i.ECP, 0) 'Item_ECP'
,IsNull(i.TaxSuffered, 0) 'Item_TaxSuffered'
,IsNull(i.Vat, 0) 'Item_Vat'
,IsNull(i.CollectTaxSuffered, 0) 'Item_CollectTaxSuffered'
,IsNull(i.Track_Batches, 0) 'Item_Track_Batches'
,IsNull(i.TrackPKD, 0) 'Item_TrackPKD'
,IsNull(i.CategoryID, 0) 'Item_CategoryID'
,IsNull(ic.Track_Inventory, 0) 'Item_TrackInventory'
,IsNull(ic.Price_Option, 0) 'Item_PriceOption'
,'' as 'Batch_Number'
,'' as 'Batch_SalePrice'
,'' as 'Batch_ecp'
,'' as 'Batch_PTR'
,'' as 'Batch_Company_Price'
,'' as 'Batch_PTS'
,'' as 'Batch_TaxSuffered'
,'' as 'Batch_ApplicableOn'
,'' as 'Batch_Partofpercentage'
,'' as 'Batch_Itemexists'
,IsNull((Case @locality When 1 Then stax.Percentage Else stax.CST_Percentage End), 0) 'SaletaxPer'
,'SaleTaxApplicableOn' = IsNull((Case @locality When 1 Then stax.LSTApplicableOn Else stax.CSTApplicableOn End), 0)
,'SaleTaxPartOff' = IsNull((Case @locality When 1 Then stax.LSTPartOff Else stax.CSTPartOff End), 0)
, IsNull((Case @locality When 1 Then tstax.Percentage Else tstax.CST_Percentage End), 0) 'TS_taxPer'
,'TS_TaxApplicableOn' = IsNull((Case @locality When 1 Then tstax.LSTApplicableOn Else tstax.CSTApplicableOn End), 0)
,'TS_TaxPartOff' = IsNull((Case @locality When 1 Then tstax.LSTPartOff Else tstax.CSTPartOff End), 0)
,'Item_Converter' = IsNull((Case When u.[UOM] = i.UOM1 Then IsNull(UOM1_Conversion, 1)
When u.[UOM] = i.UOM2 Then IsNull(UOM2_Conversion, 1) Else 1 End), 1)
,OD.Flag
,OD.ErrFlag
,Isnull((Select Sum(IsNull([FREE PERCENTAGE], 0)) from Scheme_Details S
Where S.Order_Detail_ID = OD.Det_ID and Isnull(S.SchemeID, 0) = 0
and Isnull(S.FreeProductCode, '') = '' and Isnull(FreeItemQty, 0) = 0
and Isnull(FreeitemUOMID, 0) = 0), 0) 'Discount%'
,Isnull((Select Sum(IsNull([FreeVALUE], 0)) from Scheme_Details S
Where S.Order_Detail_ID = OD.Det_ID and Isnull(S.SchemeID, 0) = 0
and Isnull(S.FreeProductCode, '') = '' and Isnull(FreeItemQty, 0) = 0
and Isnull(FreeitemUOMID, 0) = 0), 0) 'DiscountVALUE'
,Isnull(OD.Det_ID, 0) 'Det_ID' ,
isnull(OD.Serial,0) 'Serial',
cast(0 as decimal(18,6))  'SalePrice',
cast(0 as decimal(18,6))  'Qty',
cast(0 as decimal(18,6)) 'Disc',
cast(0 as decimal(18,6)) 'LST',
cast(0 as decimal(18,6)) 'CST',
cast(0 as decimal(18,6)) 'TaxSuffPer',
cast(0 as decimal(18,6)) 'UOMPrice',
0  'ApplicableOn',
cast(0 as decimal(18,6)) 'PartOff',
cast(0 as decimal(18,6)) 'TSApplicableOn',
cast(0 as decimal(18,6)) 'TSPartOff',
cast(0 as decimal(18,6)) 'ECP'
,SplitCount = @SplitCount,
Rejected = Cast(0 as Int)
into #OrdDetail
From #Ord_Det OD
Inner Join Items i On i.Product_Code = od.[ITEMID]
Inner Join ItemCategories ic On i.CategoryID = ic.Categoryid
Left Outer Join UOM u On u.UOM = od.[UOM]
Left Outer Join Tax stax On stax.tax_code = i.Sale_Tax
Left Outer Join Tax tstax On tstax.tax_code = i.TaxSuffered
Where od.[ORDERNUMBER] = @OrdNumber
and ((od.[ITEMID] in (Select  Product_Code from #Products) and isnull(@GroupID,'')<> '') Or isnull(@GroupID,'')='')
Order by OD.OrderNumber, OD.O_ItemID, OD.O_OrderedQty, OD.O_UOM, OD.Flag

--					Alter Table #OrdDetail Add Rejected int

--					Alter Table #OrdDetail Add SplitCount int

--					Update #OrdDetail Set SplitCount = @SplitCount Where ORDERNUMBER = @OrdNumber and isnull(SplitCount, 0) = 0

Drop Table #Ord_Det
Drop Table #Products
/* Detail Part Ends*/

Declare @Det_ID int
Declare @ItemFlag Int
Declare @ITEMID nVarchar(50)
Declare @ItemCode nVarchar(255)
Declare @Order_UOM_Desc nVarchar(255)
Declare @UOM_ID int
Declare @Item_UOM int
Declare @Item_UOM1 int
Declare @Item_UOM2 int
Declare @ORDEREDQTY decimal(18,6)
Declare @Item_Converter decimal(18,6)
Declare @DiscountPer decimal(18,6)
Declare @DiscountVALUE decimal(18,6)
Declare @Order_Cur_CustId nvarchar(255)
Declare @Item_PriceOption Int
Declare @Batch_Itemexists nvarchar(255)

Declare @Batch_PTS nvarchar(255)
Declare @Batch_PTR nvarchar(255)
Declare @Batch_Company_Price nvarchar(255)
Declare @Item_PTS Decimal(18,6)
Declare @Item_PTR Decimal(18,6)
Declare @Item_CompanyPrice Decimal(18,6)
Declare @SaletaxPer decimal(18,6)
Declare @SaleTaxApplicableOn Int
Declare @SaleTaxPartOff decimal(18,6)
Declare @Batch_TaxSuffered nvarchar(255)
Declare @Batch_ApplicableOn nvarchar(255)
Declare @Batch_Partofpercentage nvarchar(255)
Declare @Batch_ecp nvarchar(255)
Declare @TS_taxPer decimal(18,6)
Declare @TS_TaxApplicableOn Int
Declare @TS_TaxPartOff decimal(18,6)
Declare @Item_ECP decimal(18,6)
Declare @Item_MRP decimal(18,6)

Declare @dTaxSufferedPer decimal(18,6)
Declare @nTSApplicableOn Int
Declare @dTSPartOff decimal(18,6)
Declare @dStockist decimal(18,6)
Declare @dRetailer decimal(18,6)
Declare @dConsumer decimal(18,6)
Declare @dInstitution decimal(18,6)
Declare @dMRP decimal(18,6)

Declare @nTaxableAmount decimal(18,6)
Declare @dUOMPrice decimal(18,6)

Declare @dSPartOff decimal(18,6)
Declare @dSalePrice decimal(18,6)
Declare @dTaxSufferedAmt decimal(18,6)
Declare @Item_CollectTaxSuffered int
Declare @Item_Vat Int
Declare @dSaleTaxAmt decimal(18,6)

Declare @dVatTaxAmount decimal(18,6)

Declare @dTotalAmount decimal(18,6)
Declare @dDiscount Decimal(18,6)
Declare @dSOValue decimal(18,6)

Declare @Serial int

Set @Order_Cur_CustId = @CustID
Set @dVatTaxAmount=0
Set @dSOValue=0
Set @dSaleTaxAmt	=0
Set @dTaxSufferedAmt=0

Declare Detail Cursor For Select Det_ID,Flag,ITEMID,Item_Code,Order_UOM_Desc,UOM_ID,Item_UOM,Item_UOM1,Item_UOM2,ORDEREDQTY,Item_Converter,[Discount%],DiscountVALUE,Item_PriceOption,Batch_Itemexists,Batch_PTS,
Batch_PTR,Batch_Company_Price,Item_PTS,Item_PTR,Item_CompanyPrice,SaletaxPer,SaleTaxApplicableOn,SaleTaxPartOff,Batch_TaxSuffered,Batch_ApplicableOn,Batch_Partofpercentage,Batch_ecp,
TS_taxPer,TS_TaxApplicableOn,TS_TaxPartOff,Item_ECP,Item_MRP,Item_CollectTaxSuffered,Item_Vat,Serial from #OrdDetail
Open Detail
Fetch from Detail into @Det_ID,@ItemFlag,@ITEMID,@ItemCode,@Order_UOM_Desc,@UOM_ID,@Item_UOM,@Item_UOM1,@Item_UOM2,@ORDEREDQTY,@Item_Converter,@DiscountPer,@DiscountVALUE,@Item_PriceOption,@Batch_Itemexists,@Batch_PTS,
@Batch_PTR,@Batch_Company_Price,@Item_PTS,@Item_PTR,@Item_CompanyPrice,@SaletaxPer,@SaleTaxApplicableOn,@SaleTaxPartOff,@Batch_TaxSuffered,@Batch_ApplicableOn,@Batch_Partofpercentage,@Batch_ecp,
@TS_taxPer,@TS_TaxApplicableOn,@TS_TaxPartOff,@Item_ECP,@Item_MRP,@Item_CollectTaxSuffered,@Item_Vat,@Serial
While @@fetch_status=0
BEGIN
--Set @dVatTaxAmount=0
--Set @dSOValue=0
/* Item ID Validation */
Set @dSPartOff=@SaleTaxPartOff
if (select isnull(@ITEMID,''))=''
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' has empty Item code.'
else
Set @Error='Order number ' + @OrdNumber + ' has empty free Item code.'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END
/* Item ID and Item code Validation */
if(@ITEMID <>@ItemCode)
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' has invalid Item code [' + @ItemCode +']'
else
Set @Error='Order number ' + @OrdNumber + ' has invalid free Item code ['+ @ItemCode + ']'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END
/* UOM Validation */
if (select isnull(@Order_UOM_Desc,''))=''
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' has empty UOM for the item code [' + @ItemCode +']'
else
Set @Error='Order number ' + @OrdNumber + ' has empty UOM for the free item code [' + @ItemCode +']'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END

if(@UOM_ID <>@Item_UOM And @UOM_ID <> @Item_UOM1 And @UOM_ID <> @Item_UOM2) or @UOM_ID=0
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' has invalid UOM '+ @Order_UOM_Desc+' for the Item code [' + @ItemCode +']'
else
Set @Error='Order number ' + @OrdNumber + ' has invalid UOM ' + @Order_UOM_Desc +' for the free Item code ['+ @ItemCode + ']'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END
/* Order Qty Validation */
if (select isnull(@ORDEREDQTY,0))<=0
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' has invalid quantity ['+Cast(@ORDEREDQTY As nVarChar(50))+'] for the item code [' + @ItemCode +']'
else
Set @Error='Order number ' + @OrdNumber + ' has invalid quantity ['+Cast(@ORDEREDQTY As nVarChar(50))+'] for the free item code [' + @ItemCode +']'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END
/* Conversion Factor Validation */
if (select isnull(@Item_Converter,0))=0
BEGIN
Set @NextFlag=1

if (@ItemFlag=1)
Set @Error='Order number ' + @OrdNumber + ' - Conversion Factor for the item code [' + @ItemCode +']'
else
Set @Error='Order number ' + @OrdNumber + ' - Conversion Factor for the free item code [' + @ItemCode +']'
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber

exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipDetail
END
Set  @ORDEREDQTY = isnull(@ORDEREDQTY,0)*isnull(@Item_Converter,0)
/* Sale Price Calculation*/
Declare @SalePrice decimal(18,6)
Declare @QuotedPrice decimal(18,6)
Create Table #SalePrice(SP decimal(18,6))
--insert into #SalePrice(SP)
--exec sp_han_getQuotationPrice @Order_Cur_CustId,@ItemCode,@DocDate
Declare @QuotationType  int
Declare @QuotationId int
Declare @PurchasedAt Int
set @QuotedPrice=0
Set @PurchasedAt=0
Set @Quotationid=0
Set @QuotationType=0

Select @PurchasedAt = IsNull(Purchased_At,0),
@gst_taxid	= isnull(Sale_Tax,0) --GST_changes
from Items where Product_Code = @ItemCode

Select @Quotationid = QAbs.Quotationid,@QuotationType = QuotationType
From QuotationAbstract QAbs,QuotationCustomers QCust
Where QAbs.QuotationId = QCust.QuotationId
And @DocDate Between QAbs.ValidFromDate and QAbs.ValidToDate
And QCust.CustomerId = @Order_Cur_CustId and IsNull(QAbs.Active,0) = 1

If @QuotationType = 1 --Items
Begin
insert into #SalePrice(SP)
Select IsNull(QItems.RateQuoted,0) 'Rate'
From QuotationItems QItems
where QItems.Product_Code =@ItemCode
And QItems.QuotationId = @QuotationId
End
Else If @QuotationType = 2 or @QuotationType = 3   -- 2=>Category/3=>Manufacture
Begin
insert into #SalePrice(SP)
Select 'Rate' =
IsNull(Case
When Batch.Product_Code is NUll then
(Case QMfr.MarginOn
When 1 Then
IsNull(Items.ECP,0) - (IsNull(Items.ECP,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
Else
IsNull(Items.Purchase_Price,0) + (IsNull(Items.Purchase_Price,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
End)
Else
(Case QMfr.MarginOn
When 1 Then
IsNull(Batch.ECP,0) - (IsNull(Batch.ECP,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
Else
IsNull(Batch.PurchasePrice,0) + (IsNull(Batch.PurchasePrice,0) * (IsNull(QMfr.MarginPercentage,0) / 100))
End)
End,0)
From  QuotationMfrCategory QMfr Inner Join Items
On (
(Items.ManufacturerId = QMfr.MfrCategoryID And QuotationType = 1) Or
(Items.CategoryID = QMfr.MfrCategoryID And QuotationType = 2)
)
And QMfr.QuotationId = @QuotationId
And Items.Product_Code =@ItemCode
Left Outer Join
(Select top 1 bc.Product_Code
,bc.ECP
,"PurchasePrice" = Case @PurchasedAt
When 1 Then bc.PTS
When 2 Then bc.PTR
When 3 Then bc.Company_Price
Else bc.ECP
End
From batch_products bc  Where  bc.Product_Code = @ItemCode
And bc.Quantity > 0
And IsNull(bc.Damage, 0) = 0
And IsNull(bc.Expiry, Getdate()) >= Getdate()
Order By IsNull(bc.Free, 0), bc.Batch_Code ) Batch
On Batch.Product_Code = Items.Product_Code
End
select Top 1 @QuotedPrice=SP from #SalePrice
Drop Table #SalePrice

if(isnull(@QuotedPrice,0))=0
BEGIN
If @Item_PriceOption=1 and isnull(@Batch_Itemexists,'') <> ''
BEGIN
if(@C_CustomerCategory)=1
Set @SalePrice = @Batch_PTS
Else if (@C_CustomerCategory)=2
Set @SalePrice=@Batch_PTR
Else
Set @salePrice=@Batch_Company_Price
END
ELSE
BEGIN
if(@C_CustomerCategory)=1
Set @SalePrice = @Item_PTS
Else if (@C_CustomerCategory)=2
Set @SalePrice=@Item_PTR
Else
Set @salePrice=@Item_CompanyPrice
END
END
ELSE
BEGIN
Set @salePrice=@QuotedPrice
END



Update #OrdDetail set SalePrice=@salePrice where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set Qty=@ORDEREDQTY where OrderNumber=@OrdNumber and Item_Code=@ItemCode

if(isnull(@Batch_Itemexists,'')<>'')
BEGIN
Set @dTaxSufferedPer = @Batch_TaxSuffered
Set @nTSApplicableOn = @Batch_ApplicableOn
Set @dTSPartOff = @Batch_Partofpercentage
Set @dStockist = @Batch_PTS
Set @dRetailer = @Batch_PTR
Set @dConsumer = @Batch_ecp
Set @dInstitution = @Batch_Company_Price
END
ELSE
BEGIN
Set @dTaxSufferedPer = @TS_taxPer
Set @nTSApplicableOn = @TS_TaxApplicableOn
Set @dTSPartOff = @TS_TaxPartOff
Set @dStockist = @Item_PTS
Set @dRetailer = @Item_PTR
Set @dConsumer = @Item_ECP
Set @dInstitution = @Item_CompanyPrice
END

set @dMRP=@Item_MRP
Set @nTaxableAmount=@SalePrice
Set @dUOMPrice=@SalePrice*@Item_Converter

If @dTSPartOff = 0
Set @dTSPartOff = 100
If @dSPartOff = 0
Set @dSPartOff = 100

if (@nTSApplicableOn=1)
Set @nTaxableAmount=@SalePrice
else if (@nTSApplicableOn=2)
Set @nTaxableAmount=@dStockist
else if (@nTSApplicableOn=3)
Set @nTaxableAmount=@dRetailer
else if (@nTSApplicableOn=4)
Set @nTaxableAmount=@dConsumer
else if (@nTSApplicableOn=5)
Set @nTaxableAmount=@dInstitution
else if (@nTSApplicableOn=6)
Set @nTaxableAmount=@dMRP

Set @dTaxSufferedAmt=(isnull(@nTaxableAmount,0) * isnull(@ORDEREDQTY,0)) * ((isnull(@dTaxSufferedPer,0) * (isnull(@dTSPartOff,0) / 100.)) / 100.)

if (isnull(@Item_CollectTaxSuffered,0)=0 or isnull(@Item_Vat,0)=1)
BEGIN
Set @dTaxSufferedAmt = 0
Set @dTaxSufferedPer = 0
END

if (@SaleTaxApplicableOn=1)
Set @nTaxableAmount=@SalePrice
else if (@SaleTaxApplicableOn=2)
Set @nTaxableAmount=@dStockist
else if (@SaleTaxApplicableOn=3)
Set @nTaxableAmount=@dRetailer
else if (@SaleTaxApplicableOn=4)
Set @nTaxableAmount=@dConsumer
else if (@SaleTaxApplicableOn=5)
Set @nTaxableAmount=@dInstitution
else if (@SaleTaxApplicableOn=6)
Set @nTaxableAmount=@dMRP


--GST_Changes starts here
--Tax CS Check
if Exists(select 'x' From Tax(nolock) where Tax_Code = @gst_TaxID and isnull(CS_TaxCode,0) > 0)
Begin
--GST_Taxamount calculation
Select @dSaleTaxAmt = @ORDEREDQTY * isnull(dbo.Fn_openingbal_TaxCompCalc(@ItemCode,@gst_TaxID,@gst_taxtype,@nTaxableAmount,1,1,0),0)
End
Else
Begin
--GST_Changes ends here
if	(@SaleTaxApplicableOn=1)
Set @dSaleTaxAmt=((isnull(@nTaxableAmount,0) * isnull(@ORDEREDQTY,0)) + (isnull(@dTaxSufferedAmt,0) * isnull(@SaleTaxApplicableOn,0))) * ((isnull(@SaletaxPer,0) * (isnull(@dSPartOff,0) / 100.)) / 100.)
else
Set @dSaleTaxAmt=((isnull(@nTaxableAmount,0) * isnull(@ORDEREDQTY,0)) + (isnull(@dTaxSufferedAmt,0) * 0)) * ((isnull(@SaletaxPer,0) * (isnull(@dSPartOff,0) / 100.)) / 100.)
End --GST_Changes

if (isnull(@Item_Vat,0)=1 and isnull(@C_Locality,0)=1)
BEGIN
Set @dVatTaxAmount=isnull(@dVatTaxAmount,0)+isnull(@dSaleTaxAmt,0)
END

update #tmpSO set VatTaxAmount=isnull(@dVatTaxAmount,0) where OrderNumber=@OrdNumber
Set @dTotalAmount=isnull(@dSaleTaxAmt,0) + (((isnull(@ORDEREDQTY,0) * isnull(@SalePrice,0)) * (1 - (isnull(@DiscountPer,0) / 100.))) - isnull(@DiscountVALUE,0)) + isnull(@dTaxSufferedAmt,0)

If @SalePrice > 0
Set @dDiscount = isnull(@DiscountPer,0) + ((isnull(@DiscountVALUE,0) / (isnull(@ORDEREDQTY,0) * isnull(@SalePrice,0))) * 100.)
Else
Set @dDiscount = isnull(@DiscountPer,0)

Update #OrdDetail Set Disc=@dDiscount where OrderNumber=@OrdNumber and Item_Code=@ItemCode

Update #OrdDetail Set LST=@SaletaxPer where OrderNumber=@OrdNumber and Item_Code=@ItemCode and @C_Locality=1
Update #OrdDetail Set CST=0 where OrderNumber=@OrdNumber and Item_Code=@ItemCode and @C_Locality=1
Update #OrdDetail Set LST=0 where OrderNumber=@OrdNumber and Item_Code=@ItemCode and @C_Locality=2
Update #OrdDetail Set CST=@SaletaxPer where OrderNumber=@OrdNumber and Item_Code=@ItemCode and @C_Locality=2
Update #OrdDetail Set TaxSuffPer=@dTaxSufferedPer where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set UOMPrice=@dUOMPrice where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set ApplicableOn=@SaleTaxApplicableOn where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set PartOff=@SaleTaxPartOff where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set TSApplicableOn=@nTSApplicableOn where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set TSPartOff=@dTSPartOff where OrderNumber=@OrdNumber and Item_Code=@ItemCode
Update #OrdDetail Set ECP=@dConsumer where OrderNumber=@OrdNumber and Item_Code=@ItemCode


if (@dTotalAmount<0)
BEGIN
Set @Error='Order number ' + @OrdNumber + ' - ProductCode [' + @ItemCode +'] has Total Amount less than Zero. Invalid Order Detail informations.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
Set @dTotalAmount=0
END

Set @dSOValue=isnull(@dSOValue,0)+isnull(@dTotalAmount,0)

Update #tmpSO set SOValue=isnull(@dSOValue,0) where OrderNumber=@OrdNumber

/* Free Detail Starts*/
Select SD.[ORDERNUMBER], SD.[FreeProductCode], SD.[FreeItemQty] "FQty"
,IsNull(u.[UOM], 0) 'UOM_ID', IsNull(u.[Description], '') 'UOM_Desc'
,IsNull(i.Product_Code, '') 'Item_Code'
,IsNull(i.UOM, 0) 'Item_UOM'
,IsNull(i.UOM1, 0) 'Item_UOM1'
,IsNull(i.UOM2, 0) 'Item_UOM2'
,IsNull(i.TrackPKD, 0) 'Item_TrackPKD'
,IsNull(i.CategoryID, 0) 'Item_CategoryID'
,IsNull(ic.Track_Inventory, 0) 'Item_TrackInventory'
,IsNull(ic.Price_Option, 0) 'Item_PriceOption'
,IsNull(batch.Batch_Number, '') 'Batch_Number'
,IsNull(batch.Item_Code, '') 'Batch_Itemexists'
,'Item_Converter' = IsNull((Case When u.[UOM] = i.UOM1 Then IsNull(UOM1_Conversion, 1)
When u.[UOM] = i.UOM2 Then IsNull(UOM2_Conversion, 1) Else 1 End), 1)
,[FREE PERCENTAGE] 'Discount'
,FreeVALUE 'DiscountValue',
cast(0 as decimal(18,6))  'SalePrice',
cast(0 as decimal(18,6))  'Qty',
cast(0 as decimal(18,6)) 'Disc',
cast(0 as decimal(18,6)) 'LST',
cast(0 as decimal(18,6)) 'CST',
cast(0 as decimal(18,6)) 'TaxSuffPer',
cast(0 as decimal(18,6)) 'UOMPrice',
cast(0 as decimal(18,6)) 'ApplicableOn',
cast(0 as decimal(18,6)) 'PartOff',
cast(0 as decimal(18,6)) 'TSApplicableOn',
cast(0 as decimal(18,6)) 'TSPartOff',
cast(0 as decimal(18,6)) 'ECP'
,Rejected =  CAST(0 As Int)
into #FreeDetail
From Scheme_Details SD
Left Outer Join Items i On i.Product_Code = SD.[FreeProductCode]
Left Outer Join ItemCategories ic On i.CategoryID = ic.Categoryid
Left Outer Join UOM u On u.UOM = SD.[FreeitemUOMID]
Left Outer Join
(Select b.Product_Code 'Item_Code', b.Batch_Number, b.SalePrice,
IsNull(b.TaxSuffered, 0) TaxSuffered, IsNull(b.ecp , 0) ecp, IsNull(b.PTS,0) PTS,
IsNull(b.PTR,0) PTR, IsNull(b.Company_Price,0) Company_Price,
IsNull(b.ApplicableOn,0) ApplicableOn, IsNull(b.Partofpercentage,0) Partofpercentage
From Batch_Products b
Where b.Product_Code in (Select Distinct d.[FreeProductCode] From Scheme_Details d
Where d.[ORDERNUMBER] = @OrdNumber)
And b.batch_code = (Select top 1 bc.batch_Code
From batch_products bc Where  bc.Product_Code = b.Product_Code
And bc.Quantity > 0 And IsNull(bc.Damage, 0) = 0
And IsNull(bc.Expiry, getdate()) >= getdate()
Order By IsNull(bc.Free, 0) desc, bc.Batch_Code)) batch
On batch.Item_Code = SD.[FreeProductCode]
Where SD.[ORDERNUMBER] = @OrdNumber and SD.Order_Detail_ID = @Det_ID
and Isnull(SD.SchemeID, 0) = 0 and Isnull([FREE PERCENTAGE], 0) = 0 and Isnull(FreeVALUE, 0) = 0
Order by SD.ORDER_DETAIL_ID, SD.OrderNumber, SD.OrderedProductCode
/* Free Details Ends*/

Declare @FreeUOM_Desc nvarchar(250)
Declare @FreeItem_UOM int
Declare @FreeUOM_ID int
Declare @FreeItem_UOM1 Int
Declare @FreeItem_UOM2 Int
Declare @FreeItem_Converter decimal(18,6)
Declare @FreeItemCode nvarchar(255)
Declare @FreeQty decimal(18,6)
Declare Free Cursor For Select UOM_Desc,Item_UOM,UOM_ID,Item_UOM1,Item_UOM2,Item_Converter,Item_Code,FQty from #FreeDetail
Open Free
Fetch from Free into @FreeUOM_Desc,@FreeItem_UOM,@FreeUOM_ID,@FreeItem_UOM1,@FreeItem_UOM2,@FreeItem_Converter,@FreeItemCode,@FreeQty
While @@Fetch_status=0
BEGIN
if (isnull(@FreeUOM_Desc,'')='')
BEGIN
Set @NextFlag=1
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber
update #FreeDetail Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' has invalid UOM ' + @Order_UOM_Desc +' for the free Item code ['+ @FreeItemCode + ']'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipFree
END
if(@FreeUOM_ID <>@FreeItem_UOM And @FreeUOM_ID <> @FreeItem_UOM1 And @FreeUOM_ID <> @FreeItem_UOM2) or @FreeUOM_ID=0
BEGIN
Set @NextFlag=1
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber
update #FreeDetail Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' is not valid UOM ' + @Order_UOM_Desc +' for the free Item code ['+ @FreeItemCode + ']'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipFree
END

if (isnull(@FreeItem_Converter,0)=0)
BEGIN
Set @NextFlag=1
BEGIN TRAN
exec sp_han_updatesc @OrdNumber,2
Update #tmpSO Set Rejected=1 where OrderNumber=@OrdNumber
update #OrdDetail Set Rejected=1 where OrderNumber=@OrdNumber
update #FreeDetail Set Rejected=1 where OrderNumber=@OrdNumber

Set @Error='Order number ' + @OrdNumber + ' - Conversion Factor for the free item code [' + @FreeItemCode +']'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
COMMIT TRAN
Goto SkipFree
END

Update #FreeDetail set Qty = isnull(@FreeQty,0)*isnull(@FreeItem_Converter,0) where OrderNumber=@OrdNumber and FreeProductCode=@FreeItemCode
Fetch Next From Free into @FreeUOM_Desc,@FreeItem_UOM,@FreeUOM_ID,@FreeItem_UOM1,@FreeItem_UOM2,@FreeItem_Converter,@FreeItemCode,@FreeQty
END
SkipFree:
Close Free
Deallocate Free

insert into #FreeDetailFinal([ORDERNUMBER],[FreeProductCode],[Fqty],[UOM_ID],[UOM_Desc],[Item_Code],[Item_UOM],[Item_UOM1],[Item_UOM2],[Item_TrackPKD],[Item_CategoryID],[Item_TrackInventory],
[Item_PriceOption],[Batch_Number],[Batch_Itemexists],[Item_Converter],[Discount],[DiscountValue])
Select [ORDERNUMBER],[FreeProductCode],[Fqty],[UOM_ID],[UOM_Desc],[Item_Code],[Item_UOM],[Item_UOM1],[Item_UOM2],[Item_TrackPKD],[Item_CategoryID],[Item_TrackInventory],
[Item_PriceOption],[Batch_Number],[Batch_Itemexists],[Item_Converter],[Discount],[DiscountValue] from #FreeDetail

Drop Table #FreeDetail
if(@NextFlag=1)
Goto SkipDetail

Create Table #CGGroup(GroupDesc nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS)
--insert into #CGGroup(GroupDesc)
--exec Sp_han_GetSalesManGroup @SalesmanID,@CustID
--@SalesmanID changed to @tmpDSID for split order
declare @GrpId nvarchar(200)
set @GrpId=''
create table #TmpGrpID (GroupID int)
insert into #TmpGrpID
select distinct  cast(TDSCGM.GroupID as int) 'GroupID'
from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM on DSD.dstypeid=TDSCGM.dstypeid and DSD.SalesManid=@tmpDSID and TDSCGM.Active = 1
inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID=@CustId
where dstypectlpos = 1 and tdscgm.active = 1 order by GroupID
select  @GrpId=@GrpId+cast(GroupID as nvarchar(30))+',' from #TmpGrpID
drop table #TmpGrpID
insert into #CGGroup(GroupDesc)
select case when @GrpId='' then '' else left(@GrpId,len(@GrpId)-1) end 'SalesmanGrpID'

Declare @GroupDesc nvarchar(2000)
Select Top 1 @GroupDesc=GroupDesc from #CGGroup
Drop Table #CGGroup

Update #tmpSO set CGGroup=@GroupDesc where OrderNumber=@OrdNumber


Fetch Next from Detail into @Det_ID,@ItemFlag,@ITEMID,@ItemCode,@Order_UOM_Desc,@UOM_ID,@Item_UOM,@Item_UOM1,@Item_UOM2,@ORDEREDQTY,@Item_Converter,@DiscountPer,@DiscountVALUE,@Item_PriceOption,@Batch_Itemexists,@Batch_PTS,
@Batch_PTR,@Batch_Company_Price,@Item_PTS,@Item_PTR,@Item_CompanyPrice,@SaletaxPer,@SaleTaxApplicableOn,@SaleTaxPartOff,@Batch_TaxSuffered,@Batch_ApplicableOn,@Batch_Partofpercentage,@Batch_ecp,
@TS_taxPer,@TS_TaxApplicableOn,@TS_TaxPartOff,@Item_ECP,@Item_MRP,@Item_CollectTaxSuffered,@Item_Vat,@Serial
END
SkipDetail:
Close Detail
Deallocate Detail
--if(@NextFlag=1)
--Begin
--	Goto NextSplit
--End

If(IsNull(@NextFlag,0) = 0 )
Begin
insert into #OrdDetailFinal([ORDERNUMBER],[ITEMID],[ORDEREDQTY],[Order_UOM_Desc],[UOM_ID],[UOM_Desc],[Item_Code],[Item_UOM],[Item_UOM1],[Item_UOM2],[Item_PurchasePrice],[Item_Saleprice],
[Item_SaleTax],[Item_MRP],[Item_CompanyPrice],[Item_PTS],[Item_PTR],[Item_ECP],[Item_TaxSuffered],[Item_Vat],[Item_CollectTaxSuffered],[Item_Track_Batches],[Item_TrackPKD],[Item_CategoryID],[Item_TrackInventory],
[Item_PriceOption],[Batch_Number],[Batch_SalePrice],[Batch_ecp],[Batch_PTR],[Batch_Company_Price],[Batch_PTS],[Batch_TaxSuffered],[Batch_ApplicableOn],[Batch_Partofpercentage],[Batch_Itemexists],[SaletaxPer],[SaleTaxApplicableOn],
[SaleTaxPartOff],[TS_taxPer],[TS_TaxApplicableOn],[TS_TaxPartOff],[Item_Converter],[Flag],[ErrFlag],[Discount%],[DiscountVALUE],[Det_ID],[Rejected],
SalePrice,Qty,Disc,LST ,CST ,TaxSuffPer ,UOMPrice ,ApplicableOn,PartOff ,TSApplicableOn ,TSPartOff ,ECP, SplitCount)

Select [ORDERNUMBER],[ITEMID],[ORDEREDQTY],[Order_UOM_Desc],[UOM_ID],[UOM_Desc],[Item_Code],[Item_UOM],[Item_UOM1],[Item_UOM2],[Item_PurchasePrice],[Item_Saleprice],
[Item_SaleTax],[Item_MRP],[Item_CompanyPrice],[Item_PTS],[Item_PTR],[Item_ECP],[Item_TaxSuffered],[Item_Vat],[Item_CollectTaxSuffered],[Item_Track_Batches],[Item_TrackPKD],[Item_CategoryID],[Item_TrackInventory],
[Item_PriceOption],[Batch_Number],[Batch_SalePrice],[Batch_ecp],[Batch_PTR],[Batch_Company_Price],[Batch_PTS],[Batch_TaxSuffered],[Batch_ApplicableOn],[Batch_Partofpercentage],[Batch_Itemexists],[SaletaxPer],[SaleTaxApplicableOn],
[SaleTaxPartOff],[TS_taxPer],[TS_TaxApplicableOn],[TS_TaxPartOff],[Item_Converter],[Flag],[ErrFlag],[Discount%],[DiscountVALUE],[Det_ID],[Rejected],
SalePrice,Qty,Disc,LST ,CST ,TaxSuffPer ,UOMPrice ,ApplicableOn,PartOff ,TSApplicableOn ,TSPartOff ,ECP, SplitCount
from #OrdDetail

Drop Table #OrdDetail
End
Else
Begin
Drop Table #OrdDetail
Goto NextSplit
End

Insert Into #tmpSPLITSO(OrderNUMBER, Order_DATE, Delivery_Date, Order_SALESMANID, Order_BeatID, Order_CustID, C_BillingAddress,
C_ShippingAddress, SOValue, CreditTerm, VatTaxAmount, OrderRefNumber, CGGroup, SplitCount, GrpSalesmanID,OrderType)
Select OrderNUMBER, Order_DATE, DELIVERY_DATE, Order_SALESMANID, Order_BeatID, Order_CustID, C_BillingAddress,
C_ShippingAddress, @dSOValue, CreditTerm, @dVatTaxAmount, OrderRefNumber, CGGroup , @SplitCount, @tmpDSID,OrderType
From #tmpSO Where OrderNumber = @OrdNumber

Fetch Next from Split into @DetSalesmanID,@DetCreditTerm
END
NextSplit:
Close Split
Deallocate Split
if(@NextFlag=1)
BEGIN
Set @NextFlag=0
Goto NextOrder
END

NextOrder:

Drop Table #SplitOrders

NextOrder1:

Fetch Next from Orders into @OrdNumber,@DocDate,@C_CustomerCategory,@C_Locality

END
Close Orders
Deallocate Orders
Drop Table #Prefix
Select * into #tmpSOFinal from #tmpSO

Delete from #tmpSOFinal where ISNULL(rejected,0)=1 or ISNULL(rejected,0)=2

Delete From #tmpSPLITSO Where OrderNumber in(Select OrderNumber From #tmpSO where ISNULL(rejected,0)=1 or ISNULL(rejected,0)=2)

Declare @AbsOrdDate Datetime
Declare @AbsDeliveryDate DateTime
Declare @AbsCusID nvarchar(255)
Declare @AbsSOValue Decimal(18,6)
Declare @AbsOrderNumber nvarchar(255)
Declare @AbsBillingAddress nvarchar(4000)
Declare @AbsShippingAddress nvarchar(4000)
Declare @AbsSOStatus int
Declare @AbsCreditTerm Int
Declare @AbsOrderNumber1 nvarchar(255)
Declare @AbsIsAmended int
Declare @AbsSOReference int
Declare @AbsSalesmanID int
Declare @AbsBeatID int
Declare @AbsIs_SalesIdFromDB int
Declare @AbsVatTaxAmount decimal(18,6)
Declare @AbsCGGroup nvarchar(255)
Declare @AbsRefOrderNumber nvarchar(255)
Declare @Abs_SplitCount int
Declare @Abs_GrpSalesmanID int
Declare @Abs_OrderType Int

Create Table #tmpSOAbstract(IdentityNumber int,DocumentID int)
Declare SaveAbstract Cursor For
Select [Order_DATE],[DELIVERY_DATE],[Order_CustID],[SOValue],[OrderNUMBER],[C_BillingAddress],[C_ShippingAddress],2,[CreditTerm],[OrderNUMBER],0,0,[Order_SALESMANID],[Order_BeatID],0,
[VattaxAmount],[CGGroup],[OrderRefNumber], SplitCount, GrpSalesmanID,OrderType from #tmpSPLITSO
Open SaveAbstract
Fetch From SaveAbstract into @AbsOrdDate,@AbsDeliveryDate,@AbsCusID,@AbsSOValue,@AbsOrderNumber,@AbsBillingAddress,@AbsShippingAddress,@AbsSOStatus,@AbsCreditTerm,@AbsOrderNumber1,@AbsIsAmended,@AbsSOReference,@AbsSalesmanID,@AbsBeatID,@AbsIs_SalesIdFromDB,
@AbsVatTaxAmount,@AbsCGGroup,@AbsRefOrderNumber, @Abs_SplitCount, @Abs_GrpSalesmanID,@Abs_OrderType
While @@FETCH_STATUS=0
BEGIN
set @AbsDeliveryDate= (case When isnull(@AbsDeliveryDate,'')='' then @AbsOrdDate else @AbsDeliveryDate end)
--BEGIN TRAN
--insert into #tmpSOAbstract(IdentityNumber,DocumentID)
--Exec sp_han_Save_SOAbstract @AbsOrdDate,@AbsDeliveryDate,@AbsCusID,@AbsSOValue,@AbsOrderNumber,@AbsBillingAddress,@AbsShippingAddress,@AbsSOStatus,@AbsCreditTerm,@AbsOrderNumber1,@AbsIsAmended,@AbsSOReference,@AbsSalesmanID,@AbsBeatID,@AbsIs_SalesIdFromDB,
--   @AbsVatTaxAmount,@AbsCGGroup,0,0,@AbsRefOrderNumber

Declare @CSODate DateTime
Declare @CDeliveryDate DateTime
Declare @CCustomerID NVarChar (15)
Declare @CValue Decimal(18,6)
Declare @CPOReference NVarChar(255)
Declare @CBillAddress NVarChar(255)
Declare @CShipAddress NVarChar(255)
Declare @CStatus Int
Declare @CCreditTerm Int
Declare @CPODocReference NVarChar(255)

Declare @CIsAmEnd Int
Declare @CSORef Int
Declare @CSalesmanID Int
Declare @CBeatID Int
Declare @CIsSIDFromDB Int
Declare @CVATTaxAmount Decimal(18,6)
Declare @CCGroupID nVarchar(1000)
Declare @CForumSC Int
Declare @CSuperVisorID Int
Declare @CRefNumber NVarChar(255)

Set @CIsSIDFromDB=-1
Set @CIsAmEnd=0
Set @CSORef=0
Set @CSalesmanID =0
Set @CBeatID =0
Set @CVATTaxAmount =0
Set @CForumSC =0
Set @CSuperVisorID =0

Set @CSODate=@AbsOrdDate
Set @CDeliveryDate =@AbsDeliveryDate
Set @CCustomerID=@AbsCusID
Set @CValue=@AbsSOValue
Set @CPOReference=@AbsOrderNumber
Set @CBillAddress=@AbsBillingAddress
Set @CShipAddress=@AbsShippingAddress
Set @CStatus=@AbsSOStatus
Set @CCreditTerm=@AbsCreditTerm
Set @CPODocReference=@AbsOrderNumber1
Set @CIsAmEnd=@AbsIsAmended
Set @CSORef=@AbsSOReference
Set @CSalesmanID=@AbsSalesmanID
Set @CBeatID=@AbsBeatID
Set @CIsSIDFromDB=@AbsIs_SalesIdFromDB
Set @CVATTaxAmount=@AbsVatTaxAmount
Set @CCGroupID=@AbsCGGroup
Set @CForumSC=0
Set @CSuperVisorID=0
Set @CRefNumber=@AbsRefOrderNumber


DECLARE @CDocumentID Int
If exists ( select POReference from Soabstract where POReference = @CPOReference and GroupID =  @AbsCGGroup and forumsc = 0 )
Begin
--Select -1, -1
--Goto IfSOAlreadyExists
exec sp_han_updatesc @OrdNumber,2
Set @Error='Order number ' + @OrdNumber + ' Already exists - Unable to save sales confirmation and Rejected.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
Goto NextAbstractSave
End

BEGIN TRAN

If @CIsSIDFromDB = -1
Begin
Select @SalesmanID = ISNULL((Select SalesmanID From Beat_Salesman Where CustomerID = @CCustomerID), 0)
End
If (@CIsAmEnd=0)
Begin
--Begin Tran
Update DocumentNumbers SET DocumentID = DocumentID + 1 Where DocType = 2
Select @CDocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 2
--Commit Tran
End
Else
Begin
Select @CDocumentID=DocumentID From SoAbstract Where SoNumber=@CSORef
End

Insert Into SOAbstract
(
SODate,DeliveryDate,CustomerID,Value,POReference,BillingAddress,ShippingAddress,Status,
CreditTerm,DocumentID,PODocReference,SalesmanID,SoRef,BeatID,VatTaxAmount,GroupID,
ForumSC,SupervisorID,OrderType
)
Values
(
@CSODate,@CDeliveryDate,@CCustomerID,@CValue,@CPOReference,@CBillAddress,@CShipAddress,@CStatus,
@CCreditTerm,@CDocumentID,@CRefNumber,@CSalesmanID,@CSORef,@CBeatID,@CVATTaxAmount,@CCGroupID,
@CForumSC,@CSuperVisorID,@Abs_OrderType
)
Insert into #tmpSOAbstract(IdentityNumber,DocumentID)
Select @@Identity, @CDocumentID

--IfSOAlreadyExists:

Update SOAbstract Set TaxOnMRP = 1 Where SONumber=(Select Top 1 IdentityNumber from #tmpSOAbstract)

Declare @IdentityNumber int
Declare @DocumentID Int
Select Top 1 @IdentityNumber=IdentityNumber,@DocumentID=DocumentID from #tmpSOAbstract
Truncate Table #tmpSOAbstract
if (isnull(@IdentityNumber,0)=0 or isnull(@IdentityNumber,0)=-1)
BEGIN
ROLLBACK TRAN
Set @Error='Order number ' + @OrdNumber + ' - Unable to save sales confirmation.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
Goto NextAbstractSave
END
Declare @DET_IdentityNumber int
Declare @DET_ITEMCODE nvarchar(255)
Declare @DET_BATCHNUMBER	nvarchar(255)
Declare @DET_SALEPRICE decimal(18,6)
Declare @DET_QTY decimal(18,6)
Declare @DET_LST	decimal(18,6)
Declare @DET_DISCOUNT Decimal(18,6)
Declare @DET_CST Decimal(18,6)
Declare @DET_TAXSUFFERED Decimal(18,6)
Declare @DET_UOMID int
Declare @DET_UOMQTY Decimal(18,6)
Declare @DET_UOMPRICE Decimal(18,6)
Declare @iCnt INT
Declare @DET_VATFLAG int
Declare @DET_TAXAPPLICABLEON int
Declare @DET_TAXPARTOFF Decimal(18,6)
Declare @DET_TSAPPLICABLEON int
Declare @DET_TSPARTOFF Decimal(18,6)
Declare @DET_ECP Decimal(18,6)
Declare @DET_DETID Int
Declare @DET_SaleTax  int --GST_Changes
--Declare @ItemAlreadySaved Int

Set @iCnt=1

Declare SODETAILCur Cursor For
Select item_code,Batch_Number,saleprice,qty,LST,Disc,CST,TaxSuffPer,[UOM_ID],ORDEREDQTY, UOMPrice,Item_Vat,
ApplicableOn,PartOff ,TSApplicableOn ,TSPartOff,ECP,DET_ID,Item_SaleTax from #OrdDetailFinal	where orderNumber=@AbsOrderNumber and SplitCount = @Abs_SplitCount --GST_Changes
Union All
Select FreeProductCode,Batch_Number,0,Qty,0,0,0,0,[UOM_ID],FQty,0,0,
0,0,0,0,0,0,0 from #FreeDetailFinal where orderNumber=@AbsOrderNumber --GST_Changes
Open SODETAILCur
Fetch From SODETAILCur into @DET_ITEMCODE,@DET_BATCHNUMBER,@DET_SALEPRICE,@DET_QTY,@DET_LST,@DET_DISCOUNT,@DET_CST,@DET_TAXSUFFERED,@DET_UOMID,@DET_UOMQTY,@DET_UOMPRICE,@DET_VATFLAG,
@DET_TAXAPPLICABLEON,@DET_TAXPARTOFF,@DET_TSAPPLICABLEON,@DET_TSPARTOFF,@DET_ECP,@DET_DETID,@DET_SaleTax --GST_Changes
While @@FETCH_STATUS=0
BEGIN
--exec sp_Save_SODetail_mUOM @IdentityNumber,@DET_ITEMCODE,@DET_BATCHNUMBER,@DET_SALEPRICE,@DET_QTY,@DET_LST,@DET_DISCOUNT,@DET_CST,@DET_TAXSUFFERED,@DET_UOMID,@DET_UOMQTY,@DET_UOMPRICE,@iCnt,@DET_VATFLAG,
--@DET_TAXAPPLICABLEON,@DET_TAXPARTOFF,@DET_TSAPPLICABLEON,@DET_TSPARTOFF
Declare @DDSONumber int
Declare @DDItemCode nvarchar(15)
Declare @DDBatchNumber nvarchar(255)
Declare @DDSalePrice Decimal(18,6)
Declare @DDRequiredQuantity Decimal(18,6)
Declare @DDSaleTax Decimal(18,6)
Declare @DDDiscount Decimal(18,6)
Declare @DDTAXCODE2 float

Declare @DDTAXSUFFERED Decimal(18,6)

Declare @DDUOM int
Declare @DDUOMQty Decimal(18,6)
Declare @DDUOMPrice Decimal(18,6)

Declare @DDSerialNo Int
Declare @DDVAT int
Declare @DDTaxApplicableOn int
Declare @DDTaxPartOff decimal(18,6)
Declare @DDTaxSuffApplicableOn int
Declare @DDTaxSuffPartOff decimal(18,6)
Declare @DDMRPPerPACK decimal(18,6)
Declare @DDTaxOnQty as int

Set @DDSONumber=@IdentityNumber
Set @DDItemCode=@DET_ITEMCODE
Set @DDBatchNumber=@DET_BATCHNUMBER
Set @DDSalePrice=@DET_SALEPRICE
Set @DDRequiredQuantity=@DET_QTY
Set @DDSaleTax=@DET_LST
Set @DDDiscount=@DET_DISCOUNT
Set @DDTAXCODE2=@DET_CST
Set @DDUOM=@DET_UOMID
Set @DDUOMQty=@DET_UOMQTY
Set @DDUOMPrice=@DET_UOMPRICE

Set @DDTAXSUFFERED =0
Set @DDSerialNo=@iCnt
Set @DDVAT =@DET_VATFLAG
Set @DDTaxApplicableOn =@DET_TAXAPPLICABLEON
Set @DDTaxPartOff =@DET_TAXPARTOFF
Set @DDTaxSuffApplicableOn =@DET_TSAPPLICABLEON
Set @DDTaxSuffPartOff =@DET_TSPARTOFF
Set @DDMRPPerPACK =0
Set @DDTaxOnQty =0


IF Exists(Select 'x' From SOAbstract Where SONumber = @DDSONumber and isnull(ForumSC, 0) = 0)
Begin
Select Top 1 @DDBatchNumber = isnull(Batch_Number, '') From Batch_Products
Where Quantity > 0 and IsNull(Damage, 0) = 0
And IsNull(Expiry, getdate()) >= getdate()
And Product_Code = @DDItemCode
Order By IsNull(Free, 0), Batch_Code
End

INSERT INTO SODetail(SONumber,
Product_Code,
Batch_Number,
Quantity,
Pending,
SalePrice,
SaleTax,
Discount,
TaxCode2,
TaxSuffered,
UOM,
UOMQty,
UOMPrice,
Serial,
VAT,
TaxApplicableOn,
TaxPartOff,
TaxSuffApplicableOn,
TaxSuffPartOff,MRPPerPACK,TAXONQTY,TaxID)--GST_Changes

VALUES (@DDSONumber,
@DDItemCode,
@DDBatchNumber,
@DDRequiredQuantity,
@DDRequiredQuantity,
@DDSalePrice,
@DDSaleTax,
@DDDiscount,
@DDTAXCODE2,
@DDTAXSUFFERED,
@DDUOM ,
@DDUOMQty ,
@DDUOMPrice,
@DDSerialNo,
@DDVAT,
@DDTaxApplicableOn,
@DDTaxPartOff,
@DDTaxSuffApplicableOn,
@DDTaxSuffPartOff,
@DDMRPPerPACK,@DDTaxOnQty,@DET_SaleTax)--GST_Changes

Update SODetail Set ECP=@DET_ECP where SONumber=@IdentityNumber and product_code = @DET_ITEMCODE and Serial=@iCnt

if isnull(@DET_ID,0)>0
BEGIN
Update Scheme_Details Set Serial = @iCnt ,SaleOrderId =@IdentityNumber
where Ordernumber = @AbsOrderNumber and OrderedProductCode = @DET_ITEMCODE and Order_Detail_ID = @DET_DETID
Update Order_Details  Set Serial = @iCnt ,SaleOrderId =@IdentityNumber
where Ordernumber = @AbsOrderNumber and product_code = @DET_ITEMCODE and Order_Detail_ID = @DET_DETID
END

Set @iCnt=@iCnt+1

Fetch Next From SODETAILCur into @DET_ITEMCODE,@DET_BATCHNUMBER,@DET_SALEPRICE,@DET_QTY,@DET_LST,@DET_DISCOUNT,@DET_CST,@DET_TAXSUFFERED,@DET_UOMID,@DET_UOMQTY,@DET_UOMPRICE,@DET_VATFLAG,
@DET_TAXAPPLICABLEON,@DET_TAXPARTOFF,@DET_TSAPPLICABLEON,@DET_TSPARTOFF,@DET_ECP,@DET_DETID,@DET_SaleTax --GST_Changes
END
Close SODETAILCur
Deallocate SODETAILCur

Set @VoucherPrefix=@SOPrefix+cast(@DocumentID as nvarchar(255))

exec sp_Update_TransactionSerial 4,'',@IdentityNumber,@VoucherPrefix,0
--@AbsSalesmanID changed to @tmpDSID for Split order
Create Table #UpdateSC(SCStatus int)
Declare @UpdateSC int
Insert into #UpdateSC(SCStatus)
exec sp_han_updateSCDetail @AbsOrderNumber,1,@Abs_GrpSalesmanID
Select Top 1 @UpdateSC=SCStatus from #UpdateSC
Drop Table #UpdateSC
If @UpdateSC=0
BEGIN
Set @Error='Order number ' + @OrdNumber + ' - Unable to save Sale order Details.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
END

If (Select Top 1 TransactionDate  from Setup ) < @AbsOrdDate And @AbsOrdDate <= GETDATE()
exec sp_set_transaction_timestamp @AbsOrdDate
Else
Begin
Declare @SysDate DateTime
Set @SysDate = GETDATE()
exec sp_set_transaction_timestamp @SysDate
End

Declare @AbsSCStatus int
Create Table #UpdateSCAbstract(SCStatus int)
insert into #UpdateSCAbstract(SCStatus)
exec sp_han_updatesc @AbsOrderNumber,1
Select Top 1 @AbsSCStatus=SCStatus from #UpdateSCAbstract
Drop Table #UpdateSCAbstract

If @AbsSCStatus <> 1
BEGIN
Set @Error='Order number ' + @OrdNumber + ' - Unable to save sales confirmation.'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@Error,@SalesmanID
END

COMMIT TRAN

NextAbstractSave:
Fetch Next From SaveAbstract into @AbsOrdDate,@AbsDeliveryDate,@AbsCusID,@AbsSOValue,@AbsOrderNumber,@AbsBillingAddress,@AbsShippingAddress,@AbsSOStatus,@AbsCreditTerm,@AbsOrderNumber1,@AbsIsAmended,@AbsSOReference,@AbsSalesmanID,@AbsBeatID,@AbsIs_SalesIdFromDB,
@AbsVatTaxAmount,@AbsCGGroup,@AbsRefOrderNumber	, @Abs_SplitCount, @Abs_GrpSalesmanID,@Abs_OrderType
END
Close SaveAbstract
Deallocate SaveAbstract
Drop Table #tmpSO
Drop Table #tmpSOAbstract
Drop Table #DaycloseConfig
Drop Table #FreeDetailFinal
Drop Table #OrdDetailFinal
Drop Table #tmpSOFinal
Drop Table #tmpOrder_Header
Drop Table #tmpOrder_details
Drop Table #tmpGroupID
Drop Table #tmpSPLITSO
--			COMMIT TRAN
END TRY
BEGIN CATCH
Declare @ErrorNo nvarchar(2000)
Set @ErrorNo=@@Error
If @@TRANCOUNT >0
BEGIN
ROLLBACK TRAN
END
--Deadlock Error
If @ErrorNo='1205'
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted','Deadlocked... Application will retry to process',@SalesmanID
If @ErrorNo<>'1205'
BEGIN
Declare @err nvarchar(4000)
Set @err='Error Executing the procedure: '+cast(@ErrorNo as nvarchar(2000))
--Update Order_Header set Processed=2 where OrderNumber=@OrdNumber
exec sp_han_InsertErrorlog @OrdNumber,1,'Information','Aborted',@err,@SalesmanID
END
END CATCH
END

