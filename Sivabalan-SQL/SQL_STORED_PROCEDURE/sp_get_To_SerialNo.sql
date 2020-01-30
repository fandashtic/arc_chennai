  
Create Procedure dbo.sp_get_To_SerialNo(@Mode int,@TranID nvarchar(255)=N'',@qry nvarchar(255),@Direction int = 0, @BookMark nvarchar(128) = N'')        
As        
Declare @Query as nvarchar(4000)     
Declare @TmpStr as nvarchar(1), @DocSerialType as nvarchar(510)    
Create Table #Temp (DocTag nvarchar(20),DocumentID nvarchar(255),DocType nvarchar(200),Document nvarchar(15))      
    
Set @TmpStr=substring(@TranID,1,1)    
    
If @TmpStr='I'    
 Select @DocSerialType=IsNull(LTrim(RTrim(DocSerialType)),'') From InvoiceAbstract Where InvoiceID=substring(@TranID,2,Len(@TranID)-1)    
Else    
 Select @DocSerialType=IsNull(LTrim(RTrim(DocSerialType)),'') From DebitNote Where DebitID=substring(@TranID,2,Len(@TranID)-1)    
    
Set @DocSerialType=' And DocSerialType=''' + @DocSerialType + ''''    
    
If @TmpStr='I'    
Begin        
Set @Query=N'Select ''I''+cast(InvoiceID as varchar),Case IsNULL(GSTFlag ,0) When 0 then cast(DocumentID as Nvarchar) Else IsNULL(GSTFullDocID,'''') End DocumentID,'
Set @Query=@Query+N'Case IsNULL(GSTFlag ,0) When 0 then vp.Prefix  Else Gstvp.Prefix End DocType ,''Invoice'' as DocType '  
Set @Query=@Query+N'From InvoiceAbstract,VoucherPrefix vp,VoucherPrefix ivp,VoucherPrefix Gstvp Where (IsNull(Status,0) & 128)=0 And Balance > 0 And InvoiceType in (1,3) '        
Set @Query=@Query+N'And vp.TranID=''INVOICE'' And ivp.TranID=''INVOICE AMENDMENT'' And Gstvp.TranID =''GST_INVOICE'' And Case IsNULL(GSTFlag ,0) When 0 then cast(DocumentID as Nvarchar) Else IsNULL(GSTFullDocID,'''') End like N'''+@qry+''''  

if @Mode=5        
Set @Query=@Query+N' and PaymentMode = 0'        
End    
  
If @TmpStr='D'    
Begin        
Set @Query=N'Select ''D''+cast(DebitID as varchar),DocumentID,dvp.Prefix,''Debit Note'' '         
Set @Query=@Query+N'From DebitNote,VoucherPrefix dvp Where (IsNull(Status,0) & 64)=0 And (IsNull(Status,0) & 128)=0 And Flag <> 2 And Balance > 0 And IsNull(CustomerID,0)<>''0'' '        
Set @Query=@Query+N'And dvp.TranID=''DEBIT NOTE'' And Convert(Nvarchar,DocumentID) like N'''+@qry+''''        
End        

Insert into #Temp      
Exec sp_executesql @Query      
IF @DIRECTION = 1      
 Select Top 9 * From #Temp Where DocumentID < @BookMark Order by DocumentID Desc  
Else      
 Select Top 9 * From #Temp Order by DocumentID Desc     
Drop Table #Temp      


