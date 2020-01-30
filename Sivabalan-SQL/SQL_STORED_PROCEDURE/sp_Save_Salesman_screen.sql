CREATE Procedure sp_Save_Salesman_screen    
	(@SalesmanName NVARCHAR (255), 
	@Address NVARCHAR(255),            
	@ResNumber Varchar(20) = Null,
	@MobNumber Varchar(20) = Null,
	@Comission decimal(18,6)=0,
	@Salesmancode1 Nvarchar(15)=Null,
	@CategoryMapping Int = 1,
	@SkillLevel Int = 0,
    @Mode Int = 0, 
	@SMSAlert Int = 0
	)            
AS            
If Not Exists (Select * From Salesman Where Salesman_Name  = @SalesmanName)  
Begin  
	Insert into Salesman(Salesman_Name,Address,ResidentialNumber,MobileNumber,Commission,SalesManCode,CategoryMapping,SkillLevel, SMSAlert)
	values(@SalesmanName,@Address,@ResNumber,@MobNumber,@Comission,@Salesmancode1,@CategoryMapping,@SkillLevel, @SMSAlert)          
	Select @@Identity      
End  
else  
Begin  
	Update Salesman Set Address = @Address,ResidentialNumber = @ResNumber,MobileNumber = @MobNumber,Commission = @Comission,  
	SalesManCode =@Salesmancode1 ,CategoryMapping = @CategoryMapping , 
    SkillLevel = Case @Mode When 1 Then @SkillLevel Else IsNull(SkillLevel,0) End,
	SMSAlert = @SMSAlert
	, ModifiedDate = GetDate()  
    Where Salesman_Name  = @SalesmanName
	Select SalesmanID  From Salesman Where Salesman_Name  = @SalesmanName   
End  

