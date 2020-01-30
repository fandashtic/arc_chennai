CREATE Procedure sp_list_PurchaseReturn_DocLU( @FromDoc int,@ToDoc int,@DocumentRef nvarchar(510)=N'')  
As  
If Len(@DocumentRef)=0 
begin
	Select AdjustmentID, DocumentID,  
	AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name, AdjustmentDate, IsNull(Total_Value,0),  
	Balance, Status  ,ISNull(docreference,0),Reference,DocSerialType,GSTFlag, GSTDocID, GSTFullDocID
	From AdjustmentReturnAbstract, Vendors  
	Where AdjustmentReturnAbstract.VendorID = Vendors.VendorID And  
	(AdjustmentReturnAbstract.DocumentID Between @FromDoc And @ToDoc 
	OR (Case Isnumeric(Reference) When 1 then Cast(Reference as int)end) between @FromDoc And @ToDoc)  
	Order By AdjustmentReturnAbstract.VendorID, AdjustmentReturnAbstract.AdjustmentDate 
end
Else
Begin
	Select AdjustmentID, DocumentID,  
	AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name, AdjustmentDate, IsNull(Total_Value,0),  
	Balance, Status  ,ISNull(docreference,0),Reference,DocSerialType,GSTFlag, GSTDocID, GSTFullDocID
	From AdjustmentReturnAbstract, Vendors  
	Where AdjustmentReturnAbstract.VendorID = Vendors.VendorID And  
	Reference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(Reference,Len(@DocumentRef)+1,Len(Reference))) 
	When 1 then Cast(Substring(Reference,Len(@DocumentRef)+1,Len(Reference))as int)End) BETWEEN @FromDoc And @ToDoc
	Order By AdjustmentReturnAbstract.VendorID, AdjustmentReturnAbstract.AdjustmentDate 
End
