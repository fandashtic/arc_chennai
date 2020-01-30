CREATE Procedure sp_GetDsValue(@Position as Integer, @Active as Integer = 2)  
As  
Begin  
 Select Distinct DSTypeID,DSTypeValue From DSType_Master Where DSTypeCtlPos = @Position and Active = ( Case when @Active = 1 then 1 Else Active End ) And 
    ( Case when DSTypeCtlPos = 1 then 
        (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
      Else IsNull(OCGtype, 0) 
      End ) = IsNull(OCGtype, 0) 
End  
