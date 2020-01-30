--select * from svabstract
CREATE Procedure sp_get_ViewSV_DocLU (@DocIDFrom int,  
      @DocIDTo int,@DocumentRef nvarchar(510)='')  
as  
If Len(@DocumentRef)=0   
begin  
 Select SVAbstract.CustomerID,Customer.Company_Name,SVAbstract.SVNumber,  
 SVAbstract.SVDate, 0, Status, DocumentID,DocumentReference,'SV',SVAbstract.DocRef as SVRef  
 from SVAbstract,customer  
 where Customer.CustomerID=SVAbstract.CustomerID   
 and (SVAbstract.DocumentID between @DocIDFrom and @DocIDTo  
 OR (Case Isnumeric(DocumentReference) When 1 then Cast(DocumentReference as int)end) between @DocIDFrom And @DocIDTo)   
 order by Customer.Company_Name, SVAbstract.SVDate   
End  
Else  
Begin  
 Select SVAbstract.CustomerID,Customer.Company_Name,SVAbstract.SVNumber,  
 SVAbstract.SVDate, 0, Status, DocumentID,DocumentReference,'SV',SVAbstract.DocRef as SVRef  
 from SVAbstract,customer  
 where Customer.CustomerID=SVAbstract.CustomerID    
 AND DocumentReference LIKE  @DocumentRef + '%' + '[0-9]'  
 And (CAse ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
 When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) BETWEEN @DocIDFrom and @DocIDTo  
 order by Customer.Company_Name, SVAbstract.SVDate   
End  
  
  


