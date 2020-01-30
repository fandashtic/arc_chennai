Create procedure sp_Save_SalesmanDetail    
(@SalesmanID INT,    
 @TargetValue INT,    
 @MeasureID INT,    
 @Period INT,    
 @Remark nVarchar (255),    
 @ScopeId INt =0,  
 @salesmancode nvarchar(15) = Null)    
as insert into [SalesmanTarget]     
                (SalesmanID,    
                 Target,    
                 MeasureID,    
                 Period,    
                 Remarks,    
         Scopeid,  
     salesmancode)    
values(@salesmanID,    
       @TargetValue,    
       @MeasureID,    
       @Period,    
       @Remark,    
       @ScopeID,  
       @salesmancode)    
  
 

