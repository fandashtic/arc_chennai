CREATE Procedure sp_acc_rpt_APVDetail(@DocRef INT, @DocType INT,@Info nVarchar(4000) = Null)  
As  
Declare @APV INT        
Declare @APVDETAIL INT        
  
Set @APV = 46        
Set @APVDETAIL = 50        
  
IF @DocType = @APV  
Begin        
 Select 'Type' = Case When Type=0 then dbo.LookupDictionaryItem('Items',Default) Else (Case When Type=1 then dbo.LookupDictionaryItem('Others',Default) Else dbo.LookupDictionaryItem('Asset',Default) End) End,  
 'Account Name'=dbo.getaccountName(AccountID),'Amount'=Amount, Particular, AccountID,'DocRef' = @DocRef,   
 Type, 'Doc Type' = @APVDETAIL, Particular, 'High Light'=Case When Type=0 then 25 else (Case When Type=1 then 26 Else 27 End) End   
 from APVDetail Where DocumentID=@DocRef        
End        
Else IF @DocType = @APVDETAIL        
Begin        
 Execute sp_acc_rpt_apvsubdetail @DocRef,@Info
End        


