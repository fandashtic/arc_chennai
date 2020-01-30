
CREATE Procedure sp_han_setImplicitConfig
(@ExePath nVarchar(200),@Invoke int,@InProgress int)             
As                
Declare @Cnt as int 
Update ImplicitConfig  Set ExePath=@ExePath,Invoke=@Invoke,InProgress=@InProgress     
Set @Cnt = @@ROWCOUNT       

If @Cnt = 0 
begin
	Insert into ImplicitConfig (ExePath, Invoke, InProgress) Values (@ExePath, @Invoke, @InProgress)
	Set @Cnt = @@ROWCOUNT
end

Select "Rows" = @Cnt
