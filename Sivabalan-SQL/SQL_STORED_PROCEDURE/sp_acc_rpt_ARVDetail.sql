CREATE Procedure sp_acc_rpt_ARVDetail(@DocRef INT, @DocType INT,@Info nVarchar(4000) = Null)  
As  
Declare @ARV INT        
Declare @ARVDETAIL INT        
  
Set @ARV = 48        
Set @ARVDETAIL = 51        
  
IF @DocType = @ARV  
Begin        
 select 'Type' = Case When Type=0 then dbo.LookupDictionaryItem('Asset',Default) Else (Case When Type=1 then dbo.LookupDictionaryItem('Others',Default) Else (Case When Type=3 then dbo.LookupDictionaryItem('Credit Card',Default) Else dbo.LookupDictionaryItem('Coupon',Default) End) End ) End,
 'Account Name'=dbo.getaccountName(AccountID), 'Gross Amount'=Amount,Particular,AccountID,'Doc Ref'=@DocRef,
 Type, 'Doc Type' = @ARVDETAIL, Particular, 
 'Tax Amount' = TaxAmount, 'Net Amount' = Isnull(Amount,0) + Isnull(TaxAmount,0),
 'High Light'=Case When Type=0 then 26 Else (Case When Type=1 then 27 Else (Case When Type=3 then 48 Else 49 End) End ) End 
 from ARVDetail where DocumentID=@DocRef      
End        
Else IF @DocType = @ARVDETAIL        
Begin        
 Execute sp_acc_rpt_arvsubdetail @DocRef, @Info
End        


