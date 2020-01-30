CREATE Procedure sp_get_scheme_CHEVRON
(@SchemeID INT)          
as          
Select SchemeID, SchemeName, SchemeType, ValidFrom, ValidTo, PromptOnly, Message,           
Active, SchemeDescription, SecondaryScheme ,BudgetedAmount "BudgetAmount" , Customer "Customer"          
,HappyScheme ,FromHour ,ToHour ,FromWeekDay ,ToWeekDay ,FromDayMonth ,ToDayMonth,PaymentMode, Applyon
from Schemes         
where SchemeID=@SchemeID         

