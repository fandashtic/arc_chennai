CREATE Procedure sp_update_salesman(
	@SalesmanID INT,
	@Address nvarchar (255),
	@Active INT,    
	@ResNumber nvarchar(20) = Null,
	@MobNumber nvarchar(20) = Null,
	@Commission decimal(18,6)=0,
	@CategoryMapping Int = 1,
	@SkillLevel Int = 0,
    @Mode Int = 0, 
	@SMSAlert Int = 0)    
As    
	update [Salesman] Set 
	address=@Address,
	Active=@Active,    
	ResidentialNumber = @ResNumber, 
	MobileNumber = @MobNumber, 
	Commission=@Commission,
	CategoryMapping=@CategoryMapping,
	SkillLevel = Case @Mode When 2 Then @SkillLevel Else IsNull(SkillLevel,0) End, 
	SMSAlert = @SMSAlert 
	, ModifiedDate = GetDate()
	where SalesmanID=@salesmanID    

