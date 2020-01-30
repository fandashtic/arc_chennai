Create Procedure mERP_SP_ChangeColumnDataType(@TableName as nVarchar(1000))
As
Begin

	If Not Exists(Select * From SysColumns Where Name = 'GroupID' And xusertype = 231 
	And Id = (Select ID from Sysobjects Where  Name = @TableName And  Xtype = 'u'))
	Begin
	
		Declare @DefltConsID as Int
		Declare @DefltConsName as Varchar(1000)
	
		 /* GetDafult ConstraintID */
		Declare @SQL as nVarchar(1000)
		Select 
			@DefltConsID = isNull(CDefault,0) From SysColumns 
		Where
			ID = (Select [ID] From SysObjects Where Xtype = 'u' And Name = @TableName) And
			Name = 'GroupID'

		/* GetDafult ConstraintName */
		Set @DefltConsName = ''
		Select @DefltConsName = Name  From Sysobjects Where ID = @DefltConsID
		--Select @DefltConsName


		/* Drop Default Constraint */
		If isNull(@DefltConsName,'') <> ''
		Begin
			Set @SQL = ''
			Set @SQL = 'Alter Table ' + Cast(@TableName as nVarchar(1000)) + ' Drop Constraint ' + Cast(@DefltConsName as nVarchar(1000)) 
			Exec sp_executesql @SQL
		End 


		
		/* Invoice - Multiple Category Group Implementation - 
		Int column changed Into nVarchar column to store multiple CategoryGroup*/
		Set @SQL = ''
		Set @SQL = 'Alter Table ' + Cast(@TableName as nVarchar(1000)) + ' Alter Column GroupID  nVarchar(1000)'
		Exec sp_executesql @SQL



		/* Add Default Null Value to GroupID column */
		If isNull(@DefltConsName,'') <> ''
		Begin
			Set @SQL = ''
			Set @SQL = 'Alter Table ' + Cast(@TableName as nVarchar(1000)) +  ' Add Default(Null) For GroupID'
			Exec sp_executesql @SQL
		End

	End

End

