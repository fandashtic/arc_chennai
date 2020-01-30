Create Function mERP_fn_RFADATA_GetSchItemVal(@SchID int,@MultipleSchDetail nVarchar(1100), @Param int)
Returns Decimal(18,6)
As
Begin
  Declare @SchInfo nVarchar(1000)
  Declare @SchDelimiter varchar(1)
  Select @SchDelimiter = Char(15)
  Declare @ParamDelimiter varchar(1)
  Set @ParamDelimiter = N'|'
  Declare @SchValue Decimal(18,6)

  Select @SchInfo = ItemValue from dbo.sp_splitIn2Rows(@MultipleSchDetail,@SchDelimiter) Where ItemValue Like Cast(@SchID as nVarchar(10)) + '|%'
  Select @SchValue = Case When Charindex('E',IsNull(ItemValue,0)) > 0 Then Convert(numeric(38,6),cast(ItemValue AS float)) Else IsNull(ItemValue,0) End
                     From dbo.sp_splitIn2Rows_WithID(@SchInfo,@ParamDelimiter) Where RowID = @Param

  Return @SchValue
End
