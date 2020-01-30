CREATE procedure [dbo].[sp_list_To_InvoiceDocNo]      
(        
@SalesMan NVarChar(4000) = N'',            
@Beat NVarChar(4000) = N'',            
@TranID nvarchar(255)=N'',        
@Qry nvarchar(255),        
@Direction int = 0,         
@BookMark nvarchar(128) = N'')                  
As                  
Declare @Query as nvarchar(4000)               
Declare @DocSerialType as nvarchar(510)              
Declare @Cur_RemoveDuplicate as cursor
Declare @DocumentReference AS nvarchar(510)
    

Select @DocSerialType=IsNull(LTrim(RTrim(DocSerialType)),'') From InvoiceAbstract     
Where InvoiceID=@TranID  
 
        

Create Table #Temp (DocTag nvarchar(20),DocReference nvarchar(510),DocType nvarchar(510))               
Create Table #TempSalesman(SalesManID Int)            
Create Table #TempBeat(BeatID Int)            
            
If @SalesMan = N''            
 Begin            
  Insert InTo #TempSalesman Values(0)            
  Insert InTo #TempSalesman Select SalesmanID From SalesMan --Where Active = 1            
 End            
Else            
 Insert InTo #TempSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')             
            
If @Beat = N''             
 Begin            
  Insert InTo #TempBeat Values(0)            
  Insert InTo #TempBeat Select BeatID From Beat --Where Active = 1            
 End            
Else            
  Insert InTo #TempBeat Select * From sp_SplitIn2Rows(@Beat,N',')            
               
Insert into #temp
Select InvoiceID,DocReference,(case IsNull(DocSerialType,'') when '' then VP.Prefix else DocSerialType end) as DocType             
From InvoiceAbstract, SalesMan S, Beat B,VoucherPrefix VP 
Where IsNull(Status,0) & 128 =0           
And InvoiceID <> 0 And InvoiceType in (1,3)              
And LTrim(DocReference) like + ''+@qry+''          
AND InvoiceAbstract.SalesManID *= S.SalesManID          
AND InvoiceAbstract.BeatID *= B.BeatID          
And Isnull(InvoiceAbstract.BeatID,0) In (Select  BeatId From #TempBeat)                
And Isnull(InvoiceAbstract.SalesmanID,0) In (Select SalesmanID From #TempSalesman)                    
And DocSerialType = @DocSerialType    
And VP.TranID = N'Invoice'

IF @DIRECTION = 1                
 Select Top 9 * From #Temp Where DocReference < @BookMark Order by DocReference Desc            

Else                
 Select Top 9 * From #Temp Order by DocReference Desc               

Drop Table #Temp                
Drop Table #TempSalesman  
Drop Table #TempBeat
