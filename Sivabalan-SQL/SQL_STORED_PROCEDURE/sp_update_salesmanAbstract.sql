CREATE Procedure sp_update_salesmanAbstract(@Address nVARCHAR (255),@Active INT,    
@ResNumber Varchar(20) = Null,@MobNumber Varchar(20) = Null,@salesmancode nvarchar(15)=null)    
as    
update [Salesman] Set address=@Address,Active=@Active,    
ResidentialNumber = @ResNumber, MobileNumber = @MobNumber where SalesManCode=@salesmancode

