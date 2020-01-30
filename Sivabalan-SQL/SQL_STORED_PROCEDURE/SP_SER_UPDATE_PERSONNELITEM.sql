CREATE PROCEDURE SP_SER_UPDATE_PERSONNELITEM  
(  
@PersonnelID nvarchar(50),  
@CategoryID int,  
@ProductCode nvarchar(15))  
AS  
If Not Exists(Select * from Personnel_Item_Category where PersonnelID = @PersonnelID 
and CategoryID  = @CategoryID and Product_Code = @Productcode)
Begin	
	Insert Into Personnel_Item_Category(PersonnelID,CategoryID,Product_Code)
	Values(@PersonnelID,@CategoryID,@Productcode)
End

