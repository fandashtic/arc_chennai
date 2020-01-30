CREATE procedure sp_Get_DandD_DocID(@OperatingYear nvarchar(20))                        
as  
BEGIN                            
	Declare @GSTVoucherPrefix as nvarchar(255)   
	Declare @GSTDocID as int
	Declare @GSTFullDocID as nvarchar(100)
	Declare @Year as nvarchar(20)

	Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

	Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'DAMAGE INVOICE'
	--Select @GSTDocID = DocumentID FROM DocumentNumbers WHERE DocType = 107
	Select @GSTDocID = DocumentID FROM GSTDocumentNumbers WHERE DocType = 107 and OperatingYear = @OperatingYear
	Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))

	Select @GSTDocID, @GSTFullDocID
End
