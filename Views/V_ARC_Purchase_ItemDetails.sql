 --Select * from V_ARC_Purchase_ItemDetails Where dbo.StripTimeFromDate(BillDate) Between '04-Feb-2020' And '04-Feb-2020'
 --SELECT * FROM BillDetail T WHERE T.BillID = 1077 AND T.Product_Code = 'FL2111' AND T.Batch = '06A311219-50'
 --select * from Batch_Products T Where T.Product_Code = 'FL2111' AND T.Batch_Number = '06A311219-50'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Purchase_ItemDetails')
BEGIN
    DROP VIEW V_ARC_Purchase_ItemDetails
END
GO
Create View V_ARC_Purchase_ItemDetails
AS
select DISTINCT
	BA.BillID,
	BA.GRNID,
	BA.BillDate,
	BA.CreationTime [BillRecivedDate],
	BA.PaymentDate,
	BA.ODNumber,
	BA.InvoiceReference,
	BA.Value [BillAmount],
	BD.Product_Code,
	BD.Batch [Batch_Number],
	BD.Quantity,
	BD.PurchasePrice,
	BD.Discount,
	BD.DiscPerUnit,
	BD.DISCTYPE,
	BD.InvDiscPerc,
	BD.InvDiscAmtPerUnit,
	BD.InvDiscAmount,
	BD.OtherDiscPerc,
	(CASE WHEN ISNULL(BD.OtherDiscPerc, 0) > 0 THEN BD.OtherDiscAmount ELSE 0 END) OtherDiscPercAmount,
	BD.OtherDiscAmtPerUnit,
	(CASE WHEN ISNULL(BD.OtherDiscAmtPerUnit, 0) > 0 THEN BD.OtherDiscAmount ELSE 0 END) OtherDiscAmtPerUnitAmount,
	BD.TaxAmount,
	BD.NetPTS,
	BD.Amount [NetAmount]
FROM BillAbstract BA WITH (NOLOCK)
JOIN BillDetail BD WITH (NOLOCK) ON BD.BillID = BA.BillID
--Where dbo.StripTimeFromDate(BA.BillDate) Between '01-Jan-2020' And '04-Jan-2020'
GO
