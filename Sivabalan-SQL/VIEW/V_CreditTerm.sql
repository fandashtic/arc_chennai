CREATE  VIEW  [V_CreditTerm] 
([CreditTermID],[CreditTerm],[CreditDays],[Active])
AS
SELECT	CreditID,Description,Value,Active
from 	CreditTerm
