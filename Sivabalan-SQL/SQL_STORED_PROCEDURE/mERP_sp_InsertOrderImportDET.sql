CREATE Procedure [dbo].[mERP_sp_InsertOrderImportDET]
(
@ERPID nVarchar(50),
@ncounter int,
@ItemDetails nvarchar(2000)
)
AS
Begin
Declare @MaxID as Int
Declare @ItemCode as nvarchar(150)
Declare @ItemName as nvarchar(150)
Declare @Uom as nvarchar(150)
Declare @Qty DEcimal(18,6)
Declare @RowCount as Int
Declare @UOMID  as Int
Declare @RDate as datetime
Declare @Ddate as datetime

set dateformat DMY
--SELECT @MaxID = MAX(CAST(REPLACE(ORDERNUMBER,'ERP','') AS INT)) FROM Order_Header
--WHERE upper(SUBSTRING(ORDERNUMBER,1,3)) = 'ERP'
--
--SET @MAXID = Isnull(@MAXID,0) + 1
--Set @ERPID = 'ERP' + Cast(@MAXID as nvarchar)

Create table #TblItemDetails(ID Int identity(1,1), ItemValue nvarchar(150))
--Declare @TblItemInfo table([ID] Int Identity(1,1), ItemInfo nvarchar(2000))

--Set @ncounter = 1

--Insert Into @TblItemInfo
--select * from dbo.sp_splitin2Rows(@ItemInfo,'|')
--Set @RowCount = (select max(ID) from @TblItemInfo)


--While (@ncounter <= @RowCount)
--Begin
--Set @ItemDetails = (select ItemInfo from @TblItemInfo where [ID] = @ncounter)

Insert Into #TblItemDetails
select * from dbo.sp_splitin2Rows(@ItemDetails,'~')



Set @ItemCode = (select [ItemValue] from #TblItemDetails where [ID] = 1)
--Set @ItemName = (select [ItemValue] from #TblItemDetails where [ID] =2)
--Set @Uom = (select [ItemValue] from #TblItemDetails where [ID] = 4)
--Set @Qty = (select [ItemValue] from #TblItemDetails where [ID] = 5)
Set @Uom = (select [ItemValue] from #TblItemDetails where [ID] = 2)
Set @Qty = (select [ItemValue] from #TblItemDetails where [ID] = 3)
Select @UOMID = UOM from UOM where DEscription = @Uom
--Truncate Table #TblItemDetails
Insert Into Order_details (OrderNumber, Order_Detail_ID, Product_Code, OrderedQty, UOMID, Processed )
Values(@ERPID, @ncounter, @ItemCode, @qty, @UOMID, 0)
--Set @ncounter = @ncounter + 1
drop table #TblItemDetails
Select 1
End
