CREATE procedure Sp_Ser_rpt_PersonnelMaster  
AS  
Select PersonnelID, 'PersonnelID' = PersonnelID,PersonnelName,  
'PersonnelType' =GeneralMaster.[Description],
'PhoneNo' = PhoneNo,
'Address' = Address,  
'E_Mail' = E_mail,  
(case Isnull(Performance,0) when 0 then 'Excellent' when 1 then 'Good'   
when 2 then 'Average'when 3 then 'Poor' else '' end) as 'Performance',   
'Max Task Limit' = Noofjobs  ,     
(case PersonnelMaster.Active when 1 then 'Active' when 0 then 'Inactive'else '' end) as 'Active'   
from PersonnelMaster, GeneralMaster   
Where PersonnelMaster.PersonnelType = GeneralMaster.Code  
and Isnull(GeneralMaster.Type,0) = 0  
  



