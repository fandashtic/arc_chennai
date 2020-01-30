CREATE PROCEDURE sp_list_Wcp_DocLU (@FromDocID Bigint,@ToDocID Bigint,@DocumentRef nvarchar(510)='')      
AS      
If Len(@DocumentRef)=0       
Begin      
 SELECT WCPAbstract.salesmanid,docref,documentid,documentdate,  
 status,salesman.salesman_name,wcpabstract.code, WcpAbstract.WeekDate            
 FROM WCPAbstract,Salesman    
 WHERE wcpabstract.salesmanID = salesman.salesmancode      
 AND (DocumentID BETWEEN @FromDocID AND @ToDocID      
 OR (Case Isnumeric(DocRef) When 1 then Cast(DocRef as int)end)   
 BETWEEN @FromDocID AND @ToDocID)        
  ORDER BY salesman.salesman_Name, documentDate, code    
end      
Else      
Begin      
    
 SELECT WCPAbstract.salesmanid,docref,documentid,documentdate,  
 status,salesman.salesman_name,wcpabstract.code, WcpAbstract.WeekDate        
 FROM WCPAbstract,Salesman       
WHERE wcpabstract.salesmanID = salesman.salesmancode
 And DocRef LIKE  @DocumentRef + '%' + '[0-9]'      
 And (CAse ISnumeric(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef)))       
 When 1 then Cast(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))as int)End)   
 BETWEEN @FromDocID AND @ToDocID      
 ORDER BY salesman.salesman_Name, documentDate, code    
End      





