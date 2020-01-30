IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetPaymentType')
BEGIN
    DROP FUNCTION [fn_Arc_GetPaymentType]
END
GO
CREATE  FUNCTION fn_Arc_GetPaymentType(@PaymentMode Int)    
RETURNS NVarchar(255)    
As    
Begin    
	Declare @PaymentType as Nvarchar(255)
	Set @PaymentType = (select Top 1 value from paymentmode Where PaymentType =@PaymentMode)
	RETURN ISNULL(@PaymentType , '--')   
End    
GO