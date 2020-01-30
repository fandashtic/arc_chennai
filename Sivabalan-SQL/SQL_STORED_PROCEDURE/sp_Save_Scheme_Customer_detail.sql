CREATE procedure sp_Save_Scheme_Customer_detail    
                (@SCHEMEID INT,    
                 @CUSTOMERID nvarchar(255),    
                 @ALLOTEDAMT DECIMAL(18,6))    
As    
Insert SchemeCustomers  
                 (SchemeID,    
                  CustomerID,  
      AllotedAmount)    
values    
                 (@SCHEMEID,    
                 @CUSTOMERID,    
                 @ALLOTEDAMT)    
  


