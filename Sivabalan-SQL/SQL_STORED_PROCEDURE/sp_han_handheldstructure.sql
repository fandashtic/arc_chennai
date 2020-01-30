CREATE Procedure sp_han_handheldstructure      
as      
Declare @TableExists int      
set @TableExists = 0      
If exists (      
 select * from dbo.sysobjects       
 where id = object_id(N'[dbo].[Collection_Details]') and OBJECTPROPERTY(id, N'IsTable') = 1)      
 and exists (select * from dbo.sysobjects       
 where id = object_id(N'[dbo].[Order_Header]') and OBJECTPROPERTY(id, N'IsTable') = 1)      
 and exists (select * from dbo.sysobjects       
 where id = object_id(N'[dbo].[Order_Details]') and OBJECTPROPERTY(id, N'IsTable') = 1)       
 and exists (select * from dbo.sysobjects       
 where id = object_id(N'[dbo].[Stock_Return]') and OBJECTPROPERTY(id, N'IsTable') = 1)       
 and exists (select * from dbo.sysobjects       
 where id = object_id(N'[dbo].[Scheme_Details]') and OBJECTPROPERTY(id, N'IsTable') = 1)       
begin      
 set @TableExists  = 1      
end      
select @TableExists                       
