CREATE procedure sp_acc_prn_cus_collectiondetail(@CollectionID as int)  
as  
select   
"Document ID" = OriginalID,     
"Document Date" = DocumentDate,     
"Amount" = DocumentValue,     
"Adjusted Amount" = AdjustedAmount,     
"Document Type" =   
 case  
  when DocumentType = 1 then dbo.LookupDictionaryItem('Sales Return ',Default) 
  when DocumentType = 2 then dbo.LookupDictionaryItem('Credit Note ',Default) 
  when DocumentType = 3 then dbo.LookupDictionaryItem('Collections ',Default) 
  when DocumentType = 4 then dbo.LookupDictionaryItem('ARV ',Default)  
  when DocumentType = 5 then dbo.LookupDictionaryItem('Debit Note ',Default)  
  when DocumentType = 6 then dbo.LookupDictionaryItem('APV ',Default)  
  when DocumentType = 7 then dbo.LookupDictionaryItem('Payments ',Default) 
  when DocumentType = 8 then dbo.LookupDictionaryItem('Manual Journal ',Default)  
  when DocumentType = 9 then dbo.LookupDictionaryItem('Manual Journal ',Default)  
 end,  
"Extra Collection" = ExtraCollection,     
"Document Reference No." = DocRef    
from CollectionDetail  
where CollectionID = @CollectionID  
  
  


