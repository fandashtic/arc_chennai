CREATE procedure sp_update_scheme_ELF      
                (@SCHEMEID INT,      
                 @VALIDFROM DATETIME,      
                 @VALIDTO DATETIME,      
                 @PROMPTONLY INT,      
                 @MESSAGE NVARCHAR (255),                       
                 @Active INT,      
                 @DESCRIPTION NVARCHAR (255),      
                 @SECONDARYSCHEME INT,      
                 @HasSlabs INT,    
          @BudgetAmt Decimal(18,6) = 0,      
           @Customer int = 0,  
     @HappyScheme Integer = 0,  
     @FromHour DateTime = '',  
     @ToHour DateTime = '',  
     @FromWeekDay Integer = 0,  
     @ToWeekDay Integer = 0,  
     @FromDayMonth Integer = 0,  
     @ToDayMonth Integer = 0,
	 @ApplyOn Integer )        
as   
if @ApplyOn =0 or @ApplyOn =1   
update [Schemes] Set       
                ValidFrom=@VALIDFROM,      
                ValidTo=@VALIDTO,       
                PromptOnly=@PROMPTONLY,      
                Message=@MESSAGE,      
                Active=@ACTIVE,      
                SchemeDescription=@DESCRIPTION,      
                SecondaryScheme = @SECONDARYSCHEME,      
                HasSlabs=@HasSlabs,    
          BudgetedAmount = @BudgetAmt,      
          Customer = @Customer  ,  
    HappyScheme = @HappyScheme ,  
    FromHour = @FromHour ,  
    ToHour = @ToHour ,  
    FromWeekDay = @FromWeekDay ,  
    ToWeekDay = @ToWeekDay ,  
    FromDayMonth = @FromDayMonth ,  
    ToDayMonth = @ToDayMonth,
	Applyon = @ApplyOn    
where SchemeID=@SCHEMEID      
Else
update [Schemes] Set       
                ValidFrom=@VALIDFROM,      
                ValidTo=@VALIDTO,       
                PromptOnly=@PROMPTONLY,      
                Message=@MESSAGE,      
                Active=@ACTIVE,      
                SchemeDescription=@DESCRIPTION,      
                SecondaryScheme = @SECONDARYSCHEME,      
                HasSlabs=@HasSlabs,    
          BudgetedAmount = @BudgetAmt,      
          Customer = @Customer  ,  
    HappyScheme = @HappyScheme ,  
    FromHour = @FromHour ,  
    ToHour = @ToHour ,  
    FromWeekDay = @FromWeekDay ,  
    ToWeekDay = @ToWeekDay ,  
    FromDayMonth = @FromDayMonth ,  
    ToDayMonth = @ToDayMonth   
where SchemeID=@SCHEMEID      

    
  
  


