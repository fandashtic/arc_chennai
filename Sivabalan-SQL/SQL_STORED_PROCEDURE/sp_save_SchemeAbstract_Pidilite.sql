CREATE Procedure sp_save_SchemeAbstract_Pidilite      
        (@SCHEMENAME NVARCHAR (255),      
         @SCHEMETYPE INT,      
         @VALIDFROM DATETIME ,      
         @VALIDTO DATETIME,      
         @PROMPTONLY INT,      
         @MESSAGE NVARCHAR(255),      
         @DESCRIPTION NVARCHAR(255),      
      @SECONDARYSCHEME INT,      
      @HASSLABS int = 1,      
      @BudgetAmt Decimal(18,6) = 0,      
      @Customer int = 0,      
      @HappyScheme Integer = 0 ,      
      @FromHour DateTime = '',      
      @ToHour DateTime = '',      
      @FromWeekDay Integer = 0,      
      @ToWeekDay Integer = 0,      
      @FromDayMonth Integer = 0,      
      @ToDayMonth Integer = 0,    
      @ApplyOn Integer = null,	
      @PaymentMode nvarchar(255)=N''
      )      
AS      
if @ApplyOn =0 or @ApplyOn =1  
	Begin  
		Insert into Schemes      
		         (SchemeName,      
		         SchemeType,      
		         validFrom,      
		         ValidTo,      
		         PromptOnly,      
		         Message,      
		         SchemeDescription,      
		      HasSlabs,      
		         SecondaryScheme,      
		      BudgetedAmount,      
		   Customer,      
		      HappyScheme ,      
		      FromHour ,      
		         ToHour ,      
		      FromWeekDay ,      
		        ToWeekDay ,      
		      FromDayMonth,      
		      ToDayMonth,    
		      PaymentMode ,
			ApplyOn)      
		 values      
		         (@SCHEMENAME,      
		         @SCHEMETYPE,      
		         @VALIDFROM,      
		         @VALIDTO,      
		         @PROMPTONLY,      
		         @MESSAGE,      
		         @DESCRIPTION,      
		      @HASSLABS,      
		         @SECONDARYSCHEME,      
		         @BudgetAmt,      
		         @Customer,      
		         @HappyScheme ,      
		         @FromHour ,      
		      @ToHour ,      
		         @FromWeekDay ,      
		      @ToWeekDay ,      
		      @FromDayMonth,      
		      @ToDayMonth,    
		      @PaymentMode,
			@ApplyOn)      
	end
else
	Begin  
		Insert into Schemes      
		         (SchemeName,      
		         SchemeType,      
		         validFrom,      
		         ValidTo,      
		         PromptOnly,      
		         Message,      
		         SchemeDescription,      
		      HasSlabs,      
		         SecondaryScheme,      
		      BudgetedAmount,      
		   Customer,      
		      HappyScheme ,      
		      FromHour ,      
		         ToHour ,      
		      FromWeekDay ,      
		        ToWeekDay ,      
		      FromDayMonth,      
		      ToDayMonth,    
		      PaymentMode)      
		 values      
		         (@SCHEMENAME,      
		         @SCHEMETYPE,      
		         @VALIDFROM,      
		         @VALIDTO,      
		         @PROMPTONLY,      
		         @MESSAGE,      
		         @DESCRIPTION,      
		      @HASSLABS,      
		         @SECONDARYSCHEME,      
		         @BudgetAmt,      
		         @Customer,      
		         @HappyScheme ,      
		         @FromHour ,      
		      @ToHour ,      
		         @FromWeekDay ,      
		      @ToWeekDay ,      
		      @FromDayMonth,      
		      @ToDayMonth,    
		      @PaymentMode)      
	end
Select @@Identity      


