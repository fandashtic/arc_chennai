CREATE procedure Sp_Get_PricesFromItems(@Product_code NVarchar(15))
as
Select PTS, PTR, ECP, Company_Price, IsNull(AdhocAmount,0) from Items 
Where Product_Code = @Product_code



