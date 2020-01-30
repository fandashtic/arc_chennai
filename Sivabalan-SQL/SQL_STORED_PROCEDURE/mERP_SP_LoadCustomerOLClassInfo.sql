Create Procedure mERP_SP_LoadCustomerOLClassInfo(@CustomerCode nvarchar(100))
As
Begin
   Select distinct OCMas.Channel_Type_Code, OCMas.Channel_Type_Desc,   
   OCMas.Outlet_Type_Code, OCMas.Outlet_Type_Desc,  
   OCMas.SubOutlet_Type_Code, OCMas.SubOutlet_Type_Desc  
   From tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas, Beat
   Where OCMap.Active = 1 And         
   OCMas.ID = OCMap.OLClassID  And  
   OCMap.CustomerID=@CustomerCode 
End
