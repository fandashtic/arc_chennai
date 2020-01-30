CREATE PROCEDURE sp_get_CountSO
AS  
BEGIN
SET Dateformat dmy
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()
SELECT COUNT(*) FROM SOAbstract  
WHERE Isnull(Status,0) & 384 = 0  
AND SOAbstract.DeliveryDate <= getdate()  
And Convert(Nvarchar(10),SOAbstract.SODate,103) > @Expirydate 
END
