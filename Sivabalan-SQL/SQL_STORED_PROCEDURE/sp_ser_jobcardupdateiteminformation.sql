CREATE procedure sp_ser_jobcardupdateiteminformation(@Product_Code nvarchar(15),
@Product_Specification1 nvarchar(50),@Product_Specification2 nvarchar(50),
@Product_Specification3 nvarchar(50),@Product_Specification4 nvarchar(50),
@Product_Specification5 nvarchar(50),@DateofSale DateTime,@Color nvarchar(255),
@SoldBy nvarchar(255),@LastServiceDate Datetime, @JobCardID Int, 
@DocumentSerialNo int, @DocType int)
as
/*Item Information Product status will be 
1 -- jobEstimation is created
2 -- job card is created*/
Declare @ColorCode Int

if @Color <>''
Begin
	If Exists(Select * from GeneralMaster where Description = @Color and Type = 1)
	Begin
		Select @ColorCode = Code from GeneralMaster Where [Description] = @Color
		and Type = 1
	End
	Else
	Begin
		Insert GeneralMaster([Description],Type)
		Values(@Color,1)
		Select @ColorCode = @@Identity
	End
End

If Exists(Select * from Item_Information Where Product_Specification1 = @Product_Specification1)
Begin
	Update Item_Information
	Set Product_Specification2 = @Product_Specification2,
	Product_Specification3 = @Product_Specification3,
	Product_Specification4 = @Product_Specification4,
	Product_Specification5 = @Product_Specification5,
	Product_Code = @Product_Code,
	DateofSale = @DateofSale,
	Color = @ColorCode,
	SoldBy = @SoldBy,
	LastModifiedDate = GetDate(),
	LastServiceDate = @LastServiceDate, 
	Product_Status = 2, 
	LastJobCardId = @JobCardID
	Where Product_Specification1 = @Product_Specification1
End
Else
Begin
	Insert Item_Information (Product_Code,Product_Specification1,Product_Specification2,Product_Specification3,
	Product_Specification4,Product_Specification5,DateofSale,Color,SoldBy,LastModifiedDate,
	LastServiceDate,Product_Status, LastJobCardID)
	Values (@Product_Code,@Product_Specification1,@Product_Specification2,@Product_Specification3,
	@Product_Specification4,@Product_Specification5,@DateofSale,@ColorCode,@SoldBy,GetDate(),
	@LastServiceDate,2, @JobCardId)
End

if ((isnull(@Product_Specification2, '') <> '' or 
	isnull(@Product_Specification3, '') <> '' or 
	isnull(@Product_Specification4, '') <> '' or 
	isnull(@Product_Specification5, '') <> '' or 
	(@DateofSale is not NUll) or isnull(@ColorCode, 0) <> 0 or 
	isnull(@SoldBy, '') <> '') and 
	(Isnull(@DocumentSerialNo, 0) > 0 and Isnull(@DocType, 0) > 0) ) 	
begin 
	Insert ItemInformation_Transactions (DocumentID, DocumentType, 
	Product_Specification2, Product_Specification3, Product_Specification4,
	Product_Specification5, DateofSale, Color, SoldBy)  
	Values (@DocumentSerialNo, @DocType, 
	@Product_Specification2, @Product_Specification3, @Product_Specification4,  
	@Product_Specification5, @DateofSale, @ColorCode, @SoldBy)  	
end 


