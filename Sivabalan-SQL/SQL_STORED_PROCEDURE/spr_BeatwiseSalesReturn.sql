CREATE Procedure spr_BeatwiseSalesReturn (@BeatName nVarchar(2550),   
       @SalesReturnType nVarChar(100),  
       @FromDate DateTime,  
       @ToDate DateTime)  
As  
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
    
Create Table #tmpBeat(BeatID Int)    
If @BeatName = N'%'    
   Insert InTo #tmpBeat Select BeatID From Beat  Union Select 0  
Else    
   Insert InTo #tmpBeat select BeatID From Beat Where Beat.[Description] In   
   (Select * from dbo.sp_SplitIn2Rows(@BeatName ,@Delimeter))  
  
Create Table #temp1 (Beatid Int, Des nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS, Cus nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert InTo #temp1 Select Beat.Beatid, [Description],   
Beat_Salesman.Customerid From Beat_Salesman,  
Beat Where Beat_Salesman.Beatid = Beat.Beatid  
  
Select "BeatID" = IsNull(BeatID, 0), "Des" = Des, "Cus" = Customer.CustomerID InTo #temp2 From Customer 
Left Outer Join #temp1 ON Customer.CustomerID = #temp1.Cus

  
Select bt.BeatID, "Beat" = IsNull(bt.[Description], N'Others'), "Total Sales ReturnValue (%c)" = Sum(ids.Amount)  
From InvoiceAbstract ia, InvoiceDetail ids,  Beat bt Where  
ia.InvoiceID = ids.InvoiceID And ia.BeatID = bt.BeatID And   
bt.BeatId In (Select BeatID From  #tmpBeat)  
And ia.InvoiceDate Between @FromDate And @ToDate And InvoiceType = 4 And  
IsNull(ia.Status, 0) & 32  =   
(Case @SalesReturnType When N'Saleable' Then 0   
         When N'Damages' Then 32 Else IsNull(ia.Status, 0) & 32  End) And  
(IsNull(ia.Status, 0) & 192) = 0  
Group By bt.[Description], bt.BeatID  
  
Drop Table #temp1  
Drop Table #temp2  
Drop Table #tmpBeat  

