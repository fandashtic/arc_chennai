CREATE Procedure sp_GetDSType(@SManID As Integer, @Active as Integer = 2)  
As  
Begin  
	Select DSTypeName,DSTypeValue,DSTypeCtlPos From DSType_Master Where DsTypeID   
	In ( Select DSTypeID From DSType_Details Where SalesmanID = @SManID) and 
        ( Case when DSTypeName = 'DSType' then 
            (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
          Else IsNull(OCGtype, 0) 
          End ) = IsNull(OCGtype, 0)
	and Active = ( Case when @Active = 1 then 1 Else Active End ) Order By DSTypeCtlPos asc  
End   
