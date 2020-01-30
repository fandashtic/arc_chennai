
Create Procedure sp_CheckVanItemExists_ITC
(@GroupID nVarchar(1000), @ItemCode nvarchar(15),@VanNo int)
As

	Declare @GrpExists int
	Declare @VanExists int
	Set @GrpExists = 0
	Set @VanExists = 0

	if Len(@GroupID) > 0
	Select @GrpExists = count(Product_Code) From dbo.fn_Get_AllItems_ITC(@GroupID) Where Product_Code = @ItemCode
	
	If @VanNo > 0
	Select @VanExists = Count(Product_Code) from VanstatementDetail where Product_Code = @ItemCode and Docserial = @VanNo
	
	Set @GrpExists = IsNull(@GrpExists,0)
	Set @VanExists = IsNull(@VanExists,0)


	If @VanNo > 0 
		If @VanExists > 0
			If @GrpExists > 0
				Select 1
			Else
				If Len(@GroupID) = 0 
					Select 1
				Else
					Select 0
		Else
			Select 0
	Else
		Select 0


	
	/*if @VanNo > 0 
		if @VanExists > 0
			if @GrpExists > 0
				Select 1
			Else
				Select 0
		Else
			Select 0
	Else
		if @GrpExists > 0
			Select 0
		Else
			Select 1
	*/

