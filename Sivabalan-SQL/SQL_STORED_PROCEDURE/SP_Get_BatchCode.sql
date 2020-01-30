
Create Procedure SP_Get_BatchCode @Product_code nvarchar(15)
AS


BEGIN
	Declare @Batch_Code nVarchar(100)
	Declare @Batch_Info nvarchar(4000)
	
	Set dateformat dmy
	Declare @Last_Close_Date Datetime	
	
	Select @Last_Close_Date = DATEADD(dd, 1, LastInventoryUpload) From Setup
	
	Set @Batch_Info = ''
	Declare Cur_Batch Cursor For
	Select Batch_code From batch_products
	where isnull(creationdate,getdate())<@Last_Close_Date
		And Product_code=@Product_code
		And Quantity > 0
		and isnull(Damage,0)<>0

	
	
	Open Cur_Batch

	Fetch From Cur_Batch Into @Batch_Code
	
	While @@Fetch_Status = 0
		Begin
			Set @Batch_Info = @Batch_Info + @Batch_Code + ','
			
			Fetch From Cur_Batch Into @Batch_Code
		
		End
		Close Cur_Batch
	
		Deallocate Cur_Batch
	
	

If len(@Batch_Info) > 0
	
		Set @Batch_Info = SUBSTRING(@Batch_Info, 1, LEN(@Batch_Info) - 1)

	
Select @Batch_Info

END
