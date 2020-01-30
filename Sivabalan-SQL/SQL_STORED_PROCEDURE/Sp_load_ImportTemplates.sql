
Create Procedure Sp_load_ImportTemplates
As
Select TemplateName From ImportTemplates Where Active = 1


