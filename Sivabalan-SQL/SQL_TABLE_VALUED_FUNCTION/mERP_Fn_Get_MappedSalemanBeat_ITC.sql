CREATE Function [dbo].[mERP_Fn_Get_MappedSalemanBeat_ITC]    
(    
 @SalesManID Int =0,    
 @BeatID Int = 0,    
 @CurDate DateTime
)    
Returns @MappingTable Table    
(    
 SalesManID Int,    
 SalesMan_Name NVarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,    
 BeatID Int,    
 BeatName NVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS ,   
 CustomerID NVarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,    
 Company_Name NVarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,    
 Address NVarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS    
)    
As    
Begin


Declare @TBeat Table (BeatID Int)

If @SalesManID<>0
Begin  
  Insert into @TBeat  
  select distinct BeatID from InvoiceAbstract IA 
  where dbo.striptimefromdate(IA.InvoiceDate) between dbo.striptimefromdate(@CurDate) 
  And dbo.striptimefromdate(@CurDate) and SalesmanID=@SalesManID    
End
Else
Begin
  Insert into @TBeat
  select distinct BeatID from InvoiceAbstract IA 
  where dbo.striptimefromdate(IA.InvoiceDate) between dbo.striptimefromdate(@CurDate) 
  And dbo.striptimefromdate(@CurDate)
End

    
If @SalesManID <> 0 And @BeatID = 0   
 Insert Into @MappingTable    
 Select     
   Beat_SalesMan.SalesManID,"SalesMan_Name"=dbo.GetSalesManNameFromID(SalesManID),    
   BeatID,"Description"=dbo.GetBeatDescriptionFromID(BeatID),  
   Beat_SalesMan.CustomerID,"Company_Name"=dbo.GetCustomerNameFromID(Beat_SalesMan.CustomerID),     
   Customer.BillingAddress as Address    
 From     
   Beat_SalesMan , Customer     
 Where SalesManID=@SalesManID     
   And Beat_SalesMan.CustomerID = Customer.CustomerID
   And BeatID in (Select BeatID from @TBeat)
 Order By    
   Beat_SalesMan.SalesManID,SalesMan_Name,
   Beat_SalesMan.BeatID,    
   Description  ,Beat_SalesMan.CustomerID,Company_Name
Else if  @SalesManID = 0 And @BeatID = 0   
 Insert Into @MappingTable
 Select     
   Beat_SalesMan.SalesManID,"SalesMan_Name"=dbo.GetSalesManNameFromID(SalesManID),    
   BeatID,"Description"=dbo.GetBeatDescriptionFromID(BeatID),  
   Beat_SalesMan.CustomerID,"Company_Name"=dbo.GetCustomerNameFromID(Beat_SalesMan.CustomerID),     
   Customer.BillingAddress as Address    
 From     
   Beat_SalesMan , Customer     
 Where Beat_SalesMan.CustomerID = Customer.CustomerID
   And BeatID in (Select BeatID from @TBeat)
 Order By    
   Beat_SalesMan.SalesManID,SalesMan_Name,
   Beat_SalesMan.BeatID,    
   Description  ,Beat_SalesMan.CustomerID,Company_Name
Return    
End
