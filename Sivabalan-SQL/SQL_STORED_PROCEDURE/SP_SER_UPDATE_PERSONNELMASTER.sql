CREATE PROCEDURE SP_SER_UPDATE_PERSONNELMASTER(  
 @PersonnelID nvarchar(50),  
 @PersonnelName nvarchar(255),  
 @PersonnelType int,  
 @PhoneNo nvarchar(50),  
 @Address nvarchar(255),  
 @Email   nvarchar(50),  
 @Performance int,  
 @NoofJobs int,
@LastModifiedDate datetime,
@Active int
)  
AS  
UPDATE  PERSONNELMASTER  SET
PersonnelID = @PersonnelID, PersonnelName = @PersonnelName, 
PersonnelType = @PersonnelType,
PhoneNo = @PhoneNo,Address = @Address ,  
E_mail = @Email,
Performance = @Performance,
NoofJObs = @NoofJobs,
LastModifiedDate = @LastModifiedDate,Active = @Active  WHERE PersonnelID = @PersonnelID

