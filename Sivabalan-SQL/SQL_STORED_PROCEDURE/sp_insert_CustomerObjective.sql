CREATE procedure sp_insert_CustomerObjective    
(@CustomerId Nvarchar(15),    
 @Objyear int,    
 @Objmonth int,    
 @Volume decimal(18,6),    
 @Serial int)    
as    
Insert into CustomerObjective(Customerid,Objyear,Objmonth,Volume,Serial) 
Values (@CustomerId,@Objyear,@Objmonth,@Volume,@Serial)    
    
  


