Create Procedure sp_GSTDocNumber_Creation(@OperatingYear nvarchar(10))
As
Begin

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 101)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 101
End

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 102)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 102
End

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 103)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 103
End

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 105)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 105
End

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 106)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 106
End

IF Not Exists(Select 'x' From GSTDocumentNumbers Where OperatingYear = @OperatingYear and DocType = 107)
Begin
Insert Into GSTDocumentNumbers(OperatingYear, DocType)
Select @OperatingYear, 107
End

End
