CREATE procedure sp_Get_GSTDocID(@InvoiceType int, @GSTIPrefix nvarchar(20), @GSTSRPrefix nvarchar(20), @OperatingYear nvarchar(20))                        
as  
BEGIN                               
	Declare @GSTDocID as int
	Declare @GSTFullDocID as nvarchar(100)
	Declare @Year as nvarchar(20)

	Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

	--IF @InvoiceType = 4
	--Begin
	--	SELECT @GSTDocID =DocumentID FROM DocumentNumbers WHERE DocType = 102
	--	Select @GSTFullDocID = @GSTSRPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
	--End
	--ELSE IF @InvoiceType = 2
	--Begin
	--	SELECT @GSTDocID = DocumentID FROM DocumentNumbers WHERE DocType = 101
	--	Select @GSTFullDocID = @GSTIPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
	--End
	--ELSE
	--Begin
	--	SELECT @GSTDocID = DocumentID FROM DocumentNumbers WHERE DocType = 101
	--	Select @GSTFullDocID = @GSTIPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
	--End

	IF @InvoiceType = 4
	Begin
		SELECT @GSTDocID =DocumentID FROM GSTDocumentNumbers WHERE DocType = 102 and OperatingYear = @OperatingYear
		Select @GSTFullDocID = @GSTSRPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
	End
	ELSE
	Begin
		SELECT @GSTDocID = DocumentID FROM GSTDocumentNumbers WHERE DocType = 101 and OperatingYear = @OperatingYear
		Select @GSTFullDocID = @GSTIPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar)
	End

	Select @GSTDocID, @GSTFullDocID

End
