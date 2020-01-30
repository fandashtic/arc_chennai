Create Procedure merp_sp_list_DSTraining_DSType  
as   
Begin  
  Select Distinct DS_Mas.DSTypeID,DS_Mas.DSTypeValue   
  From DSType_Master DS_Mas, DSType_Details DS_Dt, Salesman SM_Mas   
  Where DS_Mas.DSTypeID = DS_Dt.DSTypeID  
  and DS_Mas.DSTypeCtlPos = 1 and DS_Mas.OCGtype = (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')
  and DS_Mas.Active = 1   
  and SM_Mas.SalesmanID = DS_Dt.SalesmanID  
  and SM_Mas.Active = 1 
  Order by 2   
End
