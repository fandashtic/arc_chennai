CREATE PROCEDURE mERPFYCP_get_CountRecPriceMatrix   --( @yearenddate datetime )
AS    
SELECT Count(Distinct Serial) FROM PricingAbstractReceived WHERE Flag = 0
