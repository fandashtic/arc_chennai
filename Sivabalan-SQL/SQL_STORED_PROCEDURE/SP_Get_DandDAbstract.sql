Create Procedure SP_Get_DandDAbstract(@ID int)
AS
BEGIN

Select FromMonth, ToMonth, Remarks, DaycloseDate, OptSelection, DestroyedDate, CustomerName, CustomerAddress,
DandDGreen, LegendInfo, ClaimDate
From DandDAbstract Where ID = @ID

END
