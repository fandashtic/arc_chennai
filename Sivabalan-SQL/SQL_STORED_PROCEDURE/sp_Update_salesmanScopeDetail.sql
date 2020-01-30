CREATE procedure sp_Update_salesmanScopeDetail      
 (@salesmancode nvarchar(15),      
  @scopetypevalue nvarchar(15)='',        
  @objyear int=0,    
  @objmonth int =0,    
  @objvolume decimal(18,6),    
  @serial int=0)      
       
as   

insert into [salesmanScopeDetail]       
                (SalesmanCode,      
                 ScopeTypeValue,      
        Objyear,    
        objmonth,    
        Volume,  
     Serial)                                     
values (@SalesmanCode,      
       @scopetypevalue,      
       @objyear,    
       @objmonth,    
       @objvolume,  
    @serial)

