CREATE procedure sp_Save_PointsCustomer  
                (@docserial INT,        
                 @CustomerID nvarchar(255))        
As        
Insert Into PointsCustomer(DocSerial,CustomerID)        
values(@docserial,@CustomerID)    
