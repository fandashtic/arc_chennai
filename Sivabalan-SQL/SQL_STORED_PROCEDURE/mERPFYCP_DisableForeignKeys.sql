Create Procedure mERPFYCP_DisableForeignKeys (@FullTableName nvarchar(275), @Enable int) as  
DECLARE @TableID int
DECLARE @Str nvarchar(1500)
SELECT @Str = N''
SELECT @TableID = object_id(@FullTableName) 
Declare @stzAppend nvarchar(100)
Select @Str = @Str + N' Alter table ' + SF.Name + 
    Case @Enable 
      when 1 then N' NoCheck ' 
      when 1 then N' Check '
    End 
  + N' Constraint all '
from sysreferences r, sysobjects o, sysindexes i, sysobjects sP,sysobjects SF
where r.constid = o.id  
AND o.xtype = 'F'  
AND r.rkeyindid = i.indid  
AND r.rkeyid = i.id  
And Sp.ID = R.rkeyid
And Sf.ID = R.fkeyid
AND r.rkeyid = @TABLEid
exec sp_executesql @Str
