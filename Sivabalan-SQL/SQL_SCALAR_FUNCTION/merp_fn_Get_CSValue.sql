Create Function merp_fn_Get_CSValue(@SchemeIDList nVarchar(510), @SchemeDetail nVarchar(2040), @SchemeID Int,@SplCatSchCount int=0)
Returns Decimal(18,6)
As
Begin
Declare @TempSlabInfo Table(SlabInfo nVarchar(100)) 
Declare @SchemeAmount Decimal(18,6)
Declare @Delimeter char(1)
Declare @tblSlabInfo nVarchar(100) 
Set @Delimeter = char(15)
Set @SchemeAmount = 0 
if @SplCatSchCount=0 
 set @SplCatSchCount=1

If Exists(Select * from dbo.sp_SplitIn2Rows(@SchemeIDList, ',') Where ItemValue Like @SchemeID)
Begin
   Insert into @TempSlabInfo Select * from dbo.sp_SplitIn2Rows(@SchemeDetail, @Delimeter)
   Declare GetSplVal Cursor For 
   Select SlabInfo From @TempSlabInfo 
   Open GetSplVal 
   Fetch Next From GetSplVal Into @tblSlabInfo
   While @@Fetch_status = 0  
   Begin
	If CAST(Left(@tblSlabInfo, (CharIndex(N'|',@tblSlabInfo))-1) as INT) = @SchemeID
	Begin
		Set @SchemeAmount = @SchemeAmount + Cast(SubString(@tblSlabInfo,CharIndex(N'|',@tblSlabInfo)+1,Len(@tblSlabInfo)) as Decimal(18,6)) 
	End 
	Fetch Next From GetSplVal Into @tblSlabInfo 
   End
   Close GetSplVal
   Deallocate GetSplVal
End
Return @SchemeAmount * @SplCatSchCount
End
