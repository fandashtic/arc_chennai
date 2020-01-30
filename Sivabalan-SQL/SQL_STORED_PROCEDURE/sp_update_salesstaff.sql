CREATE Procedure sp_update_salesstaff(@Address nVARCHAR (255),@Active INT,      
@ResNumber Varchar(20) = Null,@Commision decimal(18,6) = Null,@salesmancode nvarchar(15)=null)      
as      
update [Salesman] Set address=@Address,Active=@Active,      
ResidentialNumber = @ResNumber, Commission = @Commision where SalesManCode=@salesmancode

