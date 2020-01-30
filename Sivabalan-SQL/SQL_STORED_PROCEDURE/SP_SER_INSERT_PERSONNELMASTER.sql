CREATE PROCEDURE SP_SER_INSERT_PERSONNELMASTER(    
 @PersonnelID nvarchar(50),    
 @PersonnelName nvarchar(255),    
 @PersonnelType int,    
 @PhoneNo nvarchar(50),    
 @Address nvarchar(255),    
 @Email   nvarchar(50),    
 @Performance int,    
 @NoofJobs int  
)    
AS    
INSERT INTO PERSONNELMASTER    
(PersonnelID,PersonnelName,PersonnelType,PhoneNo,Address,    
E_mail,Performance,NoofJObs,Active)    
VALUES(    
@PersonnelID,     
@PersonnelName,     
@PersonnelType,     
@PhoneNo,     
@Address,     
@Email,       
@Performance,     
ISnull(@NoofJobs,0),     
 1  
)   

