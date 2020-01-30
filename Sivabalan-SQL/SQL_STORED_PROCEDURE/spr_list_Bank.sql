CREATE procedure spr_list_Bank
as
select BankCode, "Bank Code" = BankCode, "Bank Name" = BankName, "Active" = Active 
from BankMaster 
