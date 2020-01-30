Create function mERP_fn_CSMinRangeUOM(@SchemeID Int,@columnName Nvarchar(255))
Returns nVarchar(4000)
As
Begin
	Declare @tblTemp Table (ScopeValue nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @ReturnValue nVarchar(4000)
	SET @ReturnValue = ''
	Declare @ScopeValue  nVarchar(255)

	IF @columnName = 'MinRange'
	Begin
		Insert into @tblTemp 
		Select MIN_RANGE from SchMinQty Where SchemeId = @SchemeID
	End
	Else IF @columnName = 'UOM'
	Begin
		Insert into @tblTemp 
		Select (Case When UOM = 1 Then 'Base UOM'
			  When UOM = 2 Then 'UOM1'
			  When UOM = 3 Then 'UOM2'
			  When UOM = 4 Then 'Value'
			  Else Null End) UOM 
		from SchMinQty Where SchemeId = @SchemeID
	End

	Declare CurScopeValue Cursor For
	Select IsNull(ScopeValue,'') From @tblTemp Order by 1 
	Open CurScopeValue
	Fetch Next From CurScopeValue Into @ScopeValue
	While(@@fetch_status=0)        
	  Begin
		Set @ReturnValue = @ReturnValue + @ScopeValue + '|'
	  Fetch Next From CurScopeValue Into @ScopeValue
	  End
	Close CurScopeValue
	Deallocate CurScopeValue 
	
	If isnull(@ReturnValue,'') <> ''
	Begin
		SET @ReturnValue = SubString(@ReturnValue, 1, Len(@ReturnValue)-1)
	End

	Delete From @tblTemp

	Return @ReturnValue
End 
