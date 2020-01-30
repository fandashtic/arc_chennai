CREATE Procedure [dbo].[mERP_get_ReceiveCustomerDetails](
@CustID nVarchar(Max),
@RemoveID nVarchar(10) = 0
)
As

BEGIN
-- Multiple Scheme Splitup
CREATE TABLE #TSDWithIDENT_ISCH
(
[RowID]  INT IDENTITY(1,1),
[Data]  nVarchar(10) collate SQL_Latin1_General_CP1_CI_AS Not Null Default(0)
)
INSERT INTO #TSDWithIDENT_ISCH
Select LTrim(ItemValue) FROM dbo.sp_splitin2Rows(@CustID,',')

--Remove unselected Customer should be removed.
If Isnull(@RemoveID,0) > 0
Begin

Delete from #TSDWithIDENT_ISCH where Data = @RemoveID

Declare @tmp varchar(250)

SET @tmp = ''
Select @tmp = @tmp + Data + ', ' from #TSDWithIDENT_ISCH

Select "CustID" = SUBSTRING(@tmp, 0, LEN(@tmp))
End
Else
Begin
Select Data from #TSDWithIDENT_ISCH
End


Drop Table #TSDWithIDENT_ISCH
End
