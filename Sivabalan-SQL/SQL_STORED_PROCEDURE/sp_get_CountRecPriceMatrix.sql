
CREATE PROCEDURE sp_get_CountRecPriceMatrix  
AS    
SELECT Count(Distinct Serial) FROM PricingAbstractReceived WHERE Flag = 0

