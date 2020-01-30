CREATE Procedure sp_ser_checkservicetaxexists(@TaxPercentage Decimal(18,6))
as
Select * from ServiceTaxMaster Where Percentage = @TaxPercentage

