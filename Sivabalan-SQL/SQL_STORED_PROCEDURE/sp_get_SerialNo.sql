
Create Procedure dbo.sp_get_SerialNo(@Mode int,@Crit1 nvarchar(255)=N'',@Crit2 nvarchar(255)=N'',@qry nvarchar(255),@Direction int = 0, @BookMark nvarchar(128) = N'')    
as    
Declare @Query as nvarchar(4000)    
Create Table #Temp (DocTag nvarchar(20),DocumentID nvarchar(255),DocType nvarchar(200),Document nvarchar(15))  
--Balance >=0 replaced with Balance > 0 as instructed by ITC. CR NO 10959699
Set @Query=N'Select ''I''+cast(InvoiceID as varchar),Case IsNULL(GSTFlag ,0) When 0 then cast(DocumentID as Nvarchar) Else IsNULL(GSTFullDocID,'''') End DocumentID ,'
Set @Query=@Query+N'Case IsNULL(GSTFlag ,0) When 0 then vp.Prefix  Else Gstvp.Prefix End DocType ,''Invoice'' as DocType '    
Set @Query=@Query+N'From InvoiceAbstract,VoucherPrefix vp,VoucherPrefix ivp,VoucherPrefix Gstvp  Where (IsNull(Status,0) & 128)=0 And Balance > 0 '+@Crit1+' And InvoiceType in (1,3) '    
Set @Query=@Query+N'And vp.TranID=''INVOICE'' And ivp.TranID=''INVOICE AMENDMENT'' And Gstvp.TranID =''GST_INVOICE'' And Case IsNULL(GSTFlag ,0) When 0 then cast(DocumentID as Nvarchar) Else IsNULL(GSTFullDocID,'''') End like N'''+@qry+''''  
print @Query
if @Mode=5   
begin 
Set @Query=@Query+N' and PaymentMode = 0'    
end
Else    
Begin    
Set @Query=@Query+N' Union '    
Set @Query=@Query+N'Select ''D''+cast(DebitID as varchar),cast(DocumentID as NVarchar),dvp.Prefix,''Debit Note'' '     
Set @Query=@Query+N'From DebitNote,VoucherPrefix dvp Where (IsNull(Status,0) & 64)=0 And (IsNull(Status,0) & 128)=0 And Flag <> 2 And Balance > 0 '+@Crit2+' And IsNull(CustomerID,0)<>''0'' '    
Set @Query=@Query+N'And dvp.TranID=''DEBIT NOTE'' And Convert(Nvarchar,DocumentID) like N'''+@qry+'''' 

End    
Insert into #Temp  
Exec sp_executesql @Query  
IF @DIRECTION = 1  
 Select Top 9 * From #Temp Where DocumentID > @BookMark Order by DocumentID  
Else  
 Select Top 9 * From #Temp Order by DocumentID  
Drop Table #Temp  

