  
Create Procedure dbo.sp_get_DocNo(@Mode int,@Crit1 nvarchar(255)=N'',@Crit2 nvarchar(255)=N'',@qry nvarchar(255),@Direction int = 0, @BookMark nvarchar(128) = N'')    
as    
Declare @Query as nvarchar(4000)    
Create Table #Temp (DocTag nvarchar(20),DocReference nvarchar(510),DocType nvarchar(200),Document nvarchar(15))  
  
Set @Query=N'Select ''I''+cast(InvoiceID as varchar),DocReference,(case IsNull(DocSerialType,'''') when '''' then vp.Prefix else DocSerialType end) as DocType,''Invoice'' as Document '  
Set @Query=@Query+N'From InvoiceAbstract,VoucherPrefix vp,VoucherPrefix ivp Where (IsNull(Status,0) & 128)=0 And Balance > 0 '+@Crit1+' And InvoiceType in (1,3) '    
Set @Query=@Query+N'And vp.TranID=''INVOICE'' And ivp.TranID=''INVOICE AMENDMENT'' And LTrim(DocReference) like N'''+@qry+''''    
if @Mode=5    
Set @Query=@Query+N' and PaymentMode = 0'    
Else    
Begin    
Set @Query=@Query+N' Union '    
Set @Query=@Query+N'Select ''D''+cast(DebitID as varchar),DocumentReference,case IsNull(DocSerialType,'''') when '''' then dvp.Prefix else DocSerialType end,''Debit Note'' '     
Set @Query=@Query+N'From DebitNote,VoucherPrefix dvp Where (IsNull(Status,0) & 64)=0 And (IsNull(Status,0) & 128)=0 And Flag <> 2 And Balance > 0 '+@Crit2+' And IsNull(CustomerID,0)<>''0'' '    
Set @Query=@Query+N'And dvp.TranID=''DEBIT NOTE'' And LTrim(DocumentReference) like N'''+@qry+''''    
End    
  
Insert into #Temp  
Exec sp_executesql @Query  
  
IF @DIRECTION = 1   
 Select Top 9 * From #Temp where DocReference > @BookMark order by DocReference  
Else  
 Select Top 9 * From #Temp order by DocReference  
  
Drop Table #Temp  

