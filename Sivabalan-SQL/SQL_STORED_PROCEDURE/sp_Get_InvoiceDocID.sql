CREATE procedure sp_Get_InvoiceDocID(@ServiceType nvarchar(100),@OperatingYear nvarchar(20))
as
BEGIN
Declare @GSTDocID as int
Declare @GSTFullDocID as nvarchar(100)
Declare @GSTPrefix as nvarchar(50)
Select @GSTPrefix = Prefix From VoucherPrefix Where TranID = (CASE @ServiceType
WHEN 'Inward' THEN 'INWARD SERVICE INVOICE'
WHEN 'Outward' THEN 'OUTWARD SERVICE INVOICE' end)
Declare @Year as nvarchar(20)
Declare @DocType as nvarchar(20)

Select @DocType = Case @ServiceType
WHEN 'Inward' THEN   '105'
WHEN 'Outward' THEN  '106'
END


Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)
Begin
--SELECT @GSTDocID = DocumentID FROM DocumentNumbers WHERE DocType = @DocType
SELECT @GSTDocID = DocumentID FROM GSTDocumentNumbers WHERE DocType = @DocType and OperatingYear = @OperatingYear
Select @GSTFullDocID = @GSTPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
End

Select @GSTDocID, @GSTFullDocID

End
