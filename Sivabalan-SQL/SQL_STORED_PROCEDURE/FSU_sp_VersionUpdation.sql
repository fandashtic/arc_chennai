
Create Procedure dbo.[FSU_sp_VersionUpdation](  
@InstallationID int,  
@fldKeyName nvarchar(200),  
@VersionNO nvarchar(20),
@Applicable int = 2,
@FileType int  
)  
As  
if(Exists(Select * from COMVersion where ComponentName = @fldKeyName))  
 begin  
	update COMVersion set Version = @VersionNO, ModifiedDate = getDate() , Installation_ID = @InstallationID  where ComponentName = @fldKeyName  
 end  
else  
 begin  
	Insert InTo COMVersion (ComponentName,Version,Installation_ID,Recoverable,Applicable,FileType)  
	values (@fldKeyName,@VersionNO,@InstallationID,1,@Applicable,@FileType)  
 end  
