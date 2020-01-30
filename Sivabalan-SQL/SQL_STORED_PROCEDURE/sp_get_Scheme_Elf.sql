CREATE Procedure sp_get_Scheme_Elf      
(@SchemeID INT)      
as      
Select SchemeID, SchemeName, SchemeType, ValidFrom, ValidTo, PromptOnly, Message,       
Active, SchemeDescription, SecondaryScheme ,BudgetedAmount "BudgetAmount" , Customer "Customer"      
,HappyScheme ,FromHour ,ToHour ,FromWeekDay ,ToWeekDay ,FromDayMonth ,ToDayMonth,Applyon   
from Schemes     
where SchemeID=@SchemeID      
  
      
      
    
  
  
  
  


