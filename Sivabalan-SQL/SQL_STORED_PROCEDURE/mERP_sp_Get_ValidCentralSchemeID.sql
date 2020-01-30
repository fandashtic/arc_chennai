Create Procedure mERP_sp_Get_ValidCentralSchemeID(@TYPE Int, @SCHEMEID INT, @SCH_TYPE INT = 0)
AS
Begin
  Declare @TransDate DateTime
  Declare @qry nvarchar(1000)
  if @SCH_TYPE = 1 --for tradeschemes (1,2)	
	set @qry= N' and schemetype in (1,2)'
  else
	set @qry= N' and schemetype = ' + cast(@SCH_TYPE as nvarchar)
--	set @SCH_TYPE = 0

  Select Top 1 @TransDate = dbo.StripTimeFromDate(TransactionDate) From SetUp
  IF @TYPE = 1  --MOVE_NEXT
	Begin
	set @qry = N'Select Min(SchemeID) from tbl_mERP_SchemeAbstract Where SchemeID > ' + cast(@SchemeID as nvarchar) + N' And dbo.StripTimeFromDate(ViewDate) <= ''' + cast(@TransDate as nvarchar) + '''' + @Qry
	exec sp_executesql @qry
	end
  ELSE IF @TYPE = 2 --MOVE_PREV
	Begin
	set @qry = N'Select MAX(SchemeID) from tbl_mERP_SchemeAbstract Where SchemeID < ' + cast(@SchemeID as nvarchar) + N' And dbo.StripTimeFromDate(ViewDate) <= ''' + cast(@TransDate as nvarchar) + '''' + @Qry
	exec sp_executesql @qry
	end
End 
