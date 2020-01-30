Create Procedure mERP_sp_List_MinRange(@SchemeID Int)
As
Begin

	Declare @TmpItems as Table (
		Level Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Product Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		MinRange Decimal(18,6),
		UOM Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	
	Insert Into @TmpItems
	Select (Case When CATEGORY_LEVEL = 2 Then 'Division'
				  When CATEGORY_LEVEL = 3 Then 'Sub Category'
				  When CATEGORY_LEVEL = 4 Then 'Market SKU'
				  When CATEGORY_LEVEL = 5 Then 'System SKU'
				  Else Null End), Category,MIN_RANGE,
			(Case When UOM = 1 Then 'Base UOM'
				  When UOM = 2 Then 'UOM1'
				  When UOM = 3 Then 'UOM2'
				  When UOM = 4 Then 'Value'
				  Else Null End) UOM 
			From SchMinQty Where SchemeID = @SchemeID

	Update @TmpItems set MinRange = Null,UOM = Null Where Isnull(UOM,'') = '' or isnull(MinRange,0) = 0

	Select Distinct Level,Product,MinRange,UOM From @TmpItems Order by 1

	Delete From @TmpItems

End
