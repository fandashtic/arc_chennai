CREATE function sp_ser_gettax(@TaxCode Int)      
Returns Varchar(255)      
as      
Begin      
Declare @Description nvarchar(255)      
Select @Description = [Description] from serviceTaxmaster      
where ServiceTaxCode = @TaxCode      
return @Description       
End     


