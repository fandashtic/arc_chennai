CREATE procedure sp_ser_updateiteminformation(@Product_Code nvarchar(15),  
@Product_Specification1 nvarchar(50),@Product_Specification2 nvarchar(50),  
@Product_Specification3 nvarchar(50),@Product_Specification4 nvarchar(50),  
@Product_Specification5 nvarchar(50),@DateofSale DateTime,@Color nvarchar(255),  
@SoldBy nvarchar(255), @DocumentSerialNo int, @DocType as int)  
as  
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
	Set Product_Code = @Product_Code,
	Product_Specification2 = @Product_Specification2,  
	Product_Specification3 = @Product_Specification3,  
	Product_Specification4 = @Product_Specification4,  
	Product_Specification5 = @Product_Specification5,  
	DateofSale = @DateofSale,  
	Color = @ColorCode,  
	SoldBy = @SoldBy,  
	LastModifiedDate = GetDate(),  
	Product_Status = 1   
	Where Product_Specification1 = @Product_Specification1  
End  
Else  
Begin  
	Insert Item_Information (Product_Code,Product_Specification1,Product_Specification2,Product_Specification3,  
	Product_Specification4,Product_Specification5,DateofSale,Color,SoldBy,LastModifiedDate, Product_Status)  
	Values (@Product_Code,@Product_Specification1,@Product_Specification2,@Product_Specification3,@Product_Specification4,  
	@Product_Specification5,@DateofSale,@ColorCode,@SoldBy,GetDate(), 1)  
End  
  
/*   
Product Status will be 1 for job estimation .. included 15.12.2004 */  
  
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





