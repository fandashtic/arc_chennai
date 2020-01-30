
CREATE PROCEDURE sp_gather_grn_abstract_data(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT GRNID, GRNDate, CreationTime, Vendors.AlternateCode, 
GRNStatus, DocumentID, PONumbers, NewBillID
FROM GRNAbstract, Vendors
WHERE   GRNDate BETWEEN @START_DATE AND @END_DATE And
GRNAbstract.VendorID = Vendors.VendorID

