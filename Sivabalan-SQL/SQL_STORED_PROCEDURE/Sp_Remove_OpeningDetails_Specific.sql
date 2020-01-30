
Create Procedure Sp_Remove_OpeningDetails_Specific(@ITEMCODE nvarchar(50))  
AS  
Delete from Batch_Products Where Product_Code = @ITEMCODE and IsNull(DocType,0) = 6  
Delete from OpeningDetails Where Product_Code = @ITEMCODE  
If Exists (Select [ID] From sysobjects Where xType ='U' and [Name] = 'Batch_Products_Copy')
	Delete from Batch_Products_Copy  Where Product_Code = @ITEMCODE and IsNull(DocType,0) = 6  
  
