CREATE procedure sp_insert_salesmanScopeDetail  
 (@SalesmanCode nvarchar(15),  
  @scopetypevalue nvarchar(15)='',    
  @objyear int=0,
  @objmonth int =0,
  @objvolume decimal(18,6) = 0,
  @serial int=0)  
   
as insert into [salesmanScopeDetail]   
                (SalesmanCode,ScopeTypeValue,Objyear,objmonth,Volume,Serial)                                 
values (@SalesmanCode,@scopetypevalue,@objyear,@objmonth,@objvolume,@serial) 

