CREATE procedure sp_ser_loadservicetax
as
Select ServiceTaxCode, Percentage from ServiceTaxMaster 
where Active = 1 and Percentage > 0 



