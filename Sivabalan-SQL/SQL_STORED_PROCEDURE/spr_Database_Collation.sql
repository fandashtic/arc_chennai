CREATE Procedure spr_Database_Collation(@FromDate Datetime, @ToDate Datetime)                        
as  
BEGIN                               

	Declare @WDCode NVarchar(255)    
	Declare @WDDest NVarchar(255)
	Declare @CompaniesToUploadCode NVarchar(255) 

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
	Select Top 1 @WDCode = RegisteredOwner From Setup  

	If @CompaniesToUploadCode = N'ITC001'
		Set @WDDest= @WDCode  
	Else  
	Begin  
		Set @WDDest= @WDCode  
		Set @WDCode= @CompaniesToUploadCode  
	End      

	SELECT @WDCode, @WDCode as WDCode, @WDDest WDDest, @FromDate FromDate, @ToDate ToDate, [Name] [DB Name], Collation_Name [Collation Name]
	FROM sys.databases; 

End
