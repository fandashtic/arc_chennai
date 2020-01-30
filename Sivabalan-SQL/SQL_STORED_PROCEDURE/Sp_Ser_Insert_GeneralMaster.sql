CREATE PROCEDURE Sp_Ser_Insert_GeneralMaster      
(@Description nvarchar(255),      
@Type int      
)      
AS      
if Not Exists(Select * from generalmaster where Description = @Description   
and Type = @Type)  
Begin  
INSERT INTO GENERALMASTER(Description,Type)VALUES(@Description,@Type)    
End  
SELECT Code from generalmaster where Description = @Description   
and Type = @Type     

