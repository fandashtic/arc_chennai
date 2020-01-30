CREATE Procedure sp_Save_SManDSType      
(      
 @smanID Integer,@dsType1 Integer = 0,@dsType2 Integer = 0 ,@dsType3 Integer = 0,      
 @dsType4 nVarchar(100)= N'' ,@dsType5 nVarchar(100) = N'',@dsType6 nVarchar(100) = N''      
)      
As      
Begin      
      
exec sp_SaveDshandle @smanID, @dsType1
exec sp_Update_DSTypeDetails  @smanID, @dsType1,1      
exec sp_Update_DSTypeDetails  @smanID, @dsType2,2      
exec sp_Update_DSTypeDetails  @smanID, @dsType3,3      
exec sp_Update_DSTypeDetails  @smanID, @dsType4,4      
exec sp_Update_DSTypeDetails  @smanID, @dsType5,5      
exec sp_Update_DSTypeDetails  @smanID, @dsType6,6      

End      
