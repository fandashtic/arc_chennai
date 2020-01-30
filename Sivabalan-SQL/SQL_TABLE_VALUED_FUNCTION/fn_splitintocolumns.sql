Create Function dbo.fn_splitintocolumns(@Var nvarchar(max))
Returns @Result Table ([FirstValue] nvarchar(2000),[SecondValue] nvarchar(2000),[ThirdValue]nvarchar(2000))
AS
Begin
	Declare @1 as nvarchar(Max)
	Declare @2 as nvarchar(Max)
	Declare @3 as nvarchar(Max)
	Declare @tmpCurrentStr as nvarchar(Max)
	Set @1 =  SUBSTRING (@Var, 1, CHARINDEX(',', @Var,1) - 1)  
	Set @tmpCurrentStr = SUBSTRING (@Var,CHARINDEX(',', @Var,1) + 1,(Datalength(@Var) - CHARINDEX(',', @Var,1) + 1))  
	Set @2 =  SUBSTRING (@tmpCurrentStr, 1, CHARINDEX(',', @tmpCurrentStr,1) - 1)  
	Set @3 =  SUBSTRING (@tmpCurrentStr,CHARINDEX(',', @tmpCurrentStr,1) + 1,(Datalength(@tmpCurrentStr) - CHARINDEX(',', @tmpCurrentStr,1) + 1))  
	Insert Into @Result
	select @1,@2,@3
Return          
End  
