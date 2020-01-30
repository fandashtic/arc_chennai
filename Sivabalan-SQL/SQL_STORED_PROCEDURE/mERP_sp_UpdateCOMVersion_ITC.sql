CREATE procedure [dbo].[mERP_sp_UpdateCOMVersion_ITC]
As
Begin
Update COMVersion Set 
COMVersion.Version = TemplateDB.dbo.COMVersion.Version ,
Applicable = TemplateDB.dbo.COMVersion.Applicable ,
FileType = TemplateDB.dbo.COMVersion.FileType ,
Recoverable = TemplateDB.dbo.COMVersion.Recoverable ,
ModifiedDate = GetDate() 
From COMVersion , TemplateDB.dbo.COMVersion
where COMVersion.ComponentName = TemplateDB.dbo.COMVersion.ComponentName

Insert Into COMVersion (ComponentName, Version, Applicable, FileType, Recoverable) 
Select ComponentName, Version, Applicable, FileType, Recoverable 
From TemplateDB.dbo.COMVersion
Where ComponentName Not in (Select ComponentName from COMVersion)

End
