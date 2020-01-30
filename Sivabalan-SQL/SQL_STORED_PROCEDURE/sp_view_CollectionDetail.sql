Create procedure sp_view_CollectionDetail(@CollectionID as int)  
As  
Declare @SALESRETURN As NVarchar(50)    
Declare @CREDITNOTE As NVarchar(50)    
Declare @COLLECTIONS As NVarchar(50)    
Declare @INVOICE As NVarchar(50)    
Declare @DEBITNOTE As NVarchar(50)    
Declare @RETAILINVOICE As NVarchar(50)    
Declare @RETAILSALESRETURN As NVarchar(50)    
    
Declare @InvID int    
Declare @dID int     
Declare @DType int    
    
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)    
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)    
Set @COLLECTIONS = dbo.LookupDictionaryItem(N'Collections', Default)    
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)    
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)    
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)    
Set @RETAILSALESRETURN = dbo.LookupDictionaryItem(N'Retail Sales Return', Default)    
          
Select "OriginalID" = OriginalID, "DocumentDate" = CD.DocumentDate, "DocumentValue" = CD.DocumentValue,    
"AdjustedAmount" = AdjustedAmount, "DocumentTypeID" = CD.DocumentType, "Addl Adj Value" = Cd.ExtraCollection,    
"DocRef" = CD.DocRef, "Adjustment" = CD.Adjustment, "DocumentID" = CD.DocumentID,    
"DocumentType" = case convert(numeric,CD.DocumentType)    
 when 1 then @SALESRETURN    
 when 2 then @CREDITNOTE    
 when 3 then @COLLECTIONS    
 when 4 then @INVOICE    
 when 5 then @DEBITNOTE    
 when 6 then @RETAILINVOICE    
 when 7 then @RETAILSALESRETURN    
 end,    
"CollDiscPer" = IsNull(CD.Discount,0),"Flag" =
case convert(numeric,CD.DocumentType)
When 5 then
isnull(debitnote.flag,0) 
end
into #tempCollection    
From CollectionDetail CD
Left Outer Join DebitNote On CD.DocumentID = DebitID             
where CollectionID = @CollectionID    
    
 Declare getAllID Cursor For Select Distinct T.DocumentID,CD.DocumentID,Cd.DocumentType from #tempCollection T,ChequeCollDetails CD         
 Where T.DocumentTypeID in(5) And T.DocumentID = CD.DebitID and isnull(CD.debitID,0)<> 0        
Open getAllID          
Fetch From getAllID into @InvID ,@dID,@DType       
While @@fetch_status = 0          
 BEGIN          
  Update  #tempCollection Set AdjustedAmount = AdjustedAmount + (Select sum(Adjustedamount) from #tempCollection Where documentID = @InvID and documenttypeID = 5),    
  DocumentValue = documentValue +  (Select sum(DocumentValue) from #tempCollection Where documentID = @InvID and documenttypeID = 5)    
  Where DocumentID= @dID and DocumentTypeID =@dType    
Fetch Next From getAllID into @InvID ,@dID,@DType    
 END          
          
Close getAllID          
Deallocate getAllID          
  
 
if (Select count(*) from #tempCollection) = (Select count(*) from #tempCollection Where isnull(flag,0) = 2)  
BEGIN  
 Select * from #tempCollection  
END  
ELSE  
BEGIN  
 Select * from #tempCollection  where isnull(flag,0) <> 2    
END  
Drop Table #tempCollection
