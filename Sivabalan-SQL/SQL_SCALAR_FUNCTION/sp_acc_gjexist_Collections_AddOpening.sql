CREATE Function sp_acc_gjexist_Collections_AddOpening(@DocumentID Int,@FiscalYearStart DateTime)
Returns Decimal (18,6)
As
Begin
Declare @AddOpening Decimal (18,6)
Declare @OldDocID Int
Declare @OldDocType Int
Declare @OldDocDate DateTime
Declare @OldAdjustedAmount Decimal (18,6)
Declare @INVOICETYPE Int
Declare @SALESRETURNTYPE Int
Declare @CREDITNOTETYPE Int
Declare @DEBITNOTETYPE Int
Declare @ADVCOLLECTIONTYPE Int
Set @INVOICETYPE=4
Set @CREDITNOTETYPE=2
Set @ADVCOLLECTIONTYPE=3
Set @SALESRETURNTYPE=1
Set @DEBITNOTETYPE=5
Set @AddOpening = 0
If exists(Select Top 1 DocumentID From CollectionDetail Where CollectionID=@DocumentID)
Begin
	DECLARE ScanCollectionDetail CURSOR KEYSET FOR
	Select DocumentID, DocumentType,DocumentDate,AdjustedAmount From CollectionDetail 
	Where CollectionDetail.CollectionID=@DocumentID

	Open ScanCollectionDetail
	FETCH FROM ScanCollectionDetail INTO @OldDocID,@OldDocType, @OldDocDate,@OldAdjustedAmount
	WHILE @@FETCH_STATUS = 0
	BEGIN
		If dbo.stripdatefromtime(@OldDocDate) < @FiscalYearStart
		Begin
			If @OldDocType=@INVOICETYPE
			Begin
				If Not Exists(Select Top 1 InvoiceID from InvoiceAbstract where InvoiceID=@OldDocID)
				Begin
					Set @AddOpening=@AddOpening+IsNull(@OldAdjustedAmount,0)
				End
				Else
				Begin
					Set @AddOpening=@AddOpening+0
				End
			End
			Else If @OldDocType=@SALESRETURNTYPE
			Begin
				
				If Not Exists(Select Top 1 InvoiceID from InvoiceAbstract where InvoiceID=@OldDocID)
				Begin
					
					Set @OldAdjustedAmount=0-IsNull(@OldAdjustedAmount,0)
					Set @AddOpening=@AddOpening+@OldAdjustedAmount
				End
				Else
				Begin
					Set @AddOpening=@AddOpening+0
				End
			End
			Else If @OldDocType= @DEBITNOTETYPE 
			Begin
				If Not Exists(Select Top 1 DebitID from DebitNote where DebitID=@OldDocID)
				Begin
					Set @AddOpening=@AddOpening+IsNull(@OldAdjustedAmount,0)
				End
				Else
				Begin
					Set @AddOpening=@AddOpening+0
				End
			End
			Else If @OldDocType=@CREDITNOTETYPE 
			Begin
				If Not Exists(Select Top 1 CreditID from CreditNote where CreditID=@OldDocID)
				Begin
					Set @OldAdjustedAmount=0-IsNull(@OldAdjustedAmount,0)
					Set @AddOpening=@AddOpening+IsNull(@OldAdjustedAmount,0)
				End
				Else
				Begin
					Set @AddOpening=@AddOpening+0
				End
			End
			Else If @OldDocType=@ADVCOLLECTIONTYPE
			Begin
				If Not Exists(Select Top 1 DocumentID from Collections where DocumentID=@OldDocID)
				Begin
					Set @OldAdjustedAmount=0-IsNull(@OldAdjustedAmount,0)
					Set @AddOpening=@AddOpening+IsNull(@OldAdjustedAmount,0)
	
				End
				Else
				Begin
					Set @AddOpening=@AddOpening+0
				End
			End
			Else
			Begin
				Set @AddOpening=0
			End
	
		End
		Else
		Begin
			Set @AddOpening=@AddOpening+0
		End
		FETCH NEXT FROM ScanCollectionDetail INTO @OldDocID,@OldDocType, @OldDocDate,@OldAdjustedAmount
	END
	CLOSE ScanCollectionDetail
	DEALLOCATE ScanCollectionDetail
End
Else
Begin
	Set @AddOpening=0
End
Return @AddOpening
End



