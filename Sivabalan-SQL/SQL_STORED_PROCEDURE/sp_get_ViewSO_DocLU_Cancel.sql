CREATE Procedure sp_get_ViewSO_DocLU_Cancel (@DocIDFrom int,
				  @DocIDTo int,@DocumentRef nvarchar(510)=N'')
as
If Len(@DocumentRef)=0 
Begin 
	Select SOAbstract.CustomerID,Customer.Company_Name,SOAbstract.SONumber,
	SOAbstract.SODate, Value, Status, DocumentID,documentreference,DocSerialType,SoAbstract.SoRef as SORef 
	from SOAbstract,customer
	where Customer.CustomerID=SOAbstract.CustomerID 
	and (SOAbstract.DocumentID between @DocIDFrom and @DocIDTo
	OR (Case Isnumeric(documentreference) When 1 then Cast(documentreference as int)end)between @DocIDFrom And @DocIDTo) 
	--And IsNull(Status, 0) & 128 = 0
	order by Customer.Company_Name, SOAbstract.SODate 
End
Else
Begin
	Select SOAbstract.CustomerID,Customer.Company_Name,SOAbstract.SONumber,
	SOAbstract.SODate, Value, Status, DocumentID,documentreference,DocSerialType,SoAbstract.SoRef as SORef 
	from SOAbstract,customer
	where Customer.CustomerID=SOAbstract.CustomerID 
	AND documentreference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(documentreference,Len(@DocumentRef)+1,Len(documentreference))) 
	When 1 then Cast(Substring(documentreference,Len(@DocumentRef)+1,Len(documentreference))as int)End) BETWEEN @DocIDFrom and @DocIDTo
	--And IsNull(Status, 0) & 128 = 0
	order by Customer.Company_Name, SOAbstract.SODate 
End


