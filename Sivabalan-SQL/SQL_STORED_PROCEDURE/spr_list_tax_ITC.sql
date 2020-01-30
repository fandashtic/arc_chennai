
CREATE PROCEDURE spr_list_tax_ITC (@YN As nVarChar(5))
AS

Declare @ACTIVE As NVarchar(50)
Declare @INACTIVE As NVarchar(50) 
Declare @LCount As Integer
Declare @IntVar As Integer
Declare @OldID As Integer
Declare @NewID As Integer
Declare @SPP As Decimal(18, 6)
Declare @ColName As nVarchar(255)
Declare @SQLVar As nVarchar(4000)

--exec sp_executesql N'select * from items'
--exec ('select * from items')

Set @ACTIVE = dbo.LookupDictionaryItem(N'Active',Default)
Set @INACTIVE = dbo.LookupDictionaryItem(N'Inactive',Default)
Set @LCount = 0
Set @IntVar = 0
Set @OldID = 0
Set @NewID = 0

If @YN = N'Yes'
Begin
	Select @LCount = Max([Count]) 
	From (Select [Count] = Count(TaxComponent_Code)
	From TaxComponents 
	Where LST_Flag = 1
	Group By Tax_Code) sb
	
	Create Table #TaxM (Tax_Code Integer, 
	[Description] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	LST Decimal(18, 6))
	
	While @LCount > 0
	Begin
		Set @IntVar = @IntVar + 1
		Set @ColName = dbo.LookupDictionaryItem(N'LST Component ' + Cast(@IntVar As nVarchar) + N' Tax %', Default)	
	Set @SQLVar = N'Alter Table #TaxM Add [' + @ColName + N'] Decimal(18, 6) Default(0)'
	Exec(@SQLVar)
	Set @LCount = @LCount - 1
	End
	
	Set @LCount = 0
	Set @IntVar = 0
	
	Set @SQLVar = N'Alter Table #TaxM Add [CST] Decimal(18, 6) Default(0)'
	Exec(@SQLVar)
	
	Select @LCount = Max([Count]) 
	From (Select [Count] = Count(TaxComponent_Code)
	From TaxComponents 
	Where LST_Flag = 0
	Group By Tax_Code) sb
	
	While @LCount > 0
	Begin
		Set @IntVar = @IntVar + 1
--	1 Tax % CST% Level ' '
		Set @ColName = dbo.LookupDictionaryItem(N'CST Component ' + Cast(@IntVar As nVarchar) + N' Tax %', Default)	
	Set @SQLVar = N'Alter Table #TaxM Add [' + @ColName + N'] Decimal(18, 6) Default(0)'
	Exec(@SQLVar)
	Set @LCount = @LCount - 1
	End
	
	Set @SQLVar = N'Alter Table #TaxM Add [Status] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS'
	Exec(@SQLVar)
	
	Insert InTo #TaxM (Tax_Code, [Description], LST, CST, Status) 
	
	SELECT Tax_Code, Tax_Description, Percentage, CST_Percentage,
	Case Active
		WHEN 1 THEN @ACTIVE 
		ELSE @INACTIVE
		END
	FROM Tax
	
	Set @LCount = 0
	Set @IntVar = 0
	
	Select @LCount = Count(*) From #TaxM
	
	While @LCount > 0
	Begin
		Set @NewID = IsNull((Select Top 1 IsNull(Tax_Code, 0) 
		From #TaxM 
		Where Tax_Code > @OldID
		Order By Tax_Code), 0)
--n	
		DECLARE TaxCom CURSOR FOR
		SELECT tax_percentage FROM TaxComponents
		Where Tax_Code = @NewID And LST_Flag = 1
		Order By TaxComponent_Code
		OPEN TaxCom
		FETCH NEXT FROM TaxCom 
		InTo @SPP
		WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @IntVar = @IntVar + 1
			Set @ColName = dbo.LookupDictionaryItem(N'LST Component ' + Cast(@IntVar As nVarchar) + N' Tax %', Default)	
	 		Set @SQLVar = N'Update #TaxM Set [' + @ColName + N'] = ' + Cast(@SPP As nVarchar) + '
	 		Where Tax_Code = ' + Cast(@NewID As nVarChar) + ''
	 		Exec(@SQLVar)
	  	FETCH NEXT FROM TaxCom InTo @SPP
		END
		CLOSE TaxCom
		DEALLOCATE TaxCom
	
	 	Set	@IntVar = 0
--n	
		DECLARE TaxCom CURSOR FOR
		SELECT tax_percentage FROM TaxComponents
		Where Tax_Code = @NewID And LST_Flag = 0
		Order By TaxComponent_Code
		OPEN TaxCom
		FETCH NEXT FROM TaxCom 
		InTo @SPP
		WHILE @@FETCH_STATUS = 0
		BEGIN
			Set @IntVar = @IntVar + 1
			Set @ColName = dbo.LookupDictionaryItem(N'CST Component ' + Cast(@IntVar As nVarchar) + N' Tax %', Default)	
			Set @SQLVar = N'Update #TaxM Set [' + @ColName + N'] = ' + Cast(@SPP As nVarchar) + '
			Where Tax_Code = ' + Cast(@NewID As nVarChar)  + ''
			Exec(@SQLVar)
	  	FETCH NEXT FROM TaxCom InTo @SPP
		END
		CLOSE TaxCom
		DEALLOCATE TaxCom
	
		Set	@IntVar = 0	
		Set @OldID = @NewID
		Set @LCount = @LCount - 1
	End
	
	Select * From #TaxM Order By Tax_Code
	Drop Table #TaxM

End
Else
Begin

	SELECT Tax_Code, "Description" = Tax_Description, "LST" = Percentage, "CST" = CST_Percentage,
		"Status" = case Active
		WHEN 1 THEN @ACTIVE 
		ELSE @INACTIVE
		END
	FROM Tax
End

