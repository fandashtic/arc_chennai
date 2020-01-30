Create Procedure SP_TaxExistence ( @taxCode nVarchar(100), @Flag int )
As
Select count(*)  From taxComponents where Tax_Code = @taxCode  and Lst_Flag = @Flag
