CREATE Procedure sp_Get_CalculateTax_ItemInfo 
(@Product_Code nvarchar(20), @Batch nvarchar(128))
As
Declare @Count Int
Select @Count = Count(*) from Batch_Products Where Product_Code=@Product_Code and Batch_Number=@Batch
If @Count > 0
	Select Top 1 Batch_Products.PTS,   
		Batch_Products.PTR,   
		Batch_Products.ECP,   
		Batch_Products.Company_Price,   
		Items.MRP   
		From Items, Batch_Products  
		Where Items.Product_Code = Batch_Products.Product_Code   
		And Items.Product_Code = @Product_Code  
		And Batch_Products.Batch_Number = @Batch  
		And IsNull(Batch_Products.Free, 0) = 0  
		And IsNull(Batch_Products.Damage, 0) = 0  
		Order By Batch_Products.Batch_Code Desc  
Else
	Select PTS, PTR, ECP, Company_Price, MRP From Items 
	Where Product_Code = @Product_Code  


