CREATE procedure [dbo].[spr_list_Salesman_wise_Collections_Ageing_analysis]    
(@SALESMAN nvarchar(50),               
@FROMDATE DATETIME ,               
@TODATE DATETIME )     
as    
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
  
Declare @OnetoSeven Decimal(18,6)    
Declare @EighttoTen Decimal(18,6)      
Declare @EleventoFourteen Decimal(18,6)    
Declare @FifteentoTwentyOne Decimal(18,6)    
Declare @TwentyTwotoThirty Decimal(18,6)    
Declare @LessthanThirty Decimal(18,6)    
Declare @ThirtyOnetoSixty Decimal(18,6)    
Declare @SixtyOnetoNinety Decimal(18,6)    
Declare @MorethanNinety Decimal(18,6)    
    
    
Declare @One As Datetime      
Declare @Seven As Datetime      
Declare @Eight As Datetime    
Declare @Ten As Datetime    
Declare @Eleven As Datetime    
Declare @Fourteen As Datetime    
Declare @Fifteen As Datetime    
Declare @TwentyOne As Datetime    
Declare @TwentyTwo As Datetime    
Declare @Thirty As Datetime    
Declare @ThirtyOne As Datetime    
Declare @Sixty As Datetime    
Declare @SixtyOne As Datetime    
Declare @Ninety As Datetime    
    
    
Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + '/' +      
Cast(Datepart(mm, GetDate()) As nvarchar) + '/' +      
Cast(Datepart(yyyy, GetDate()) As nvarchar)      
Set @Seven = DateAdd(d, -7, @One)      
Set @Eight = DateAdd(d, -1, @Seven)      
Set @Ten = DateAdd(d, -2, @Eight)    
Set @Eleven = DateAdd(d, -1, @Ten)    
Set @Fourteen = DateAdd(d, -3, @Eleven)    
Set @Fifteen = DateAdd(d, -1, @Fourteen)    
Set @TwentyOne = DateAdd(d, -6, @Fifteen)    
Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)    
Set @Thirty = DateAdd(d, -8, @TwentyTwo)    
Set @ThirtyOne = DateAdd(d, -1, @Thirty)    
Set @Sixty = DateAdd(d, -29, @ThirtyOne)    
Set @SixtyOne = DateAdd(d, -1, @Sixty)    
Set @Ninety = DateAdd(d, -29, @SixtyOne)    
    
Set @One = dbo.MakeDayEnd(@One)    
Set @Eight = dbo.MakeDayEnd(@Eight)    
Set @Eleven = dbo.MakeDayEnd(@Eleven)    
Set @Fifteen = dbo.MakeDayEnd(@Fifteen)    
Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)    
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)    
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)    
  
  
  
create table #temp    
(SalesmanID nvarchar(15),      
Salesman_Name nvarchar(50),  
Value Decimal(18,6) null,    
OnetoSeven Decimal(18,6) null,    
EighttoTen Decimal(18,6) null,    
EleventoFourteen Decimal(18,6) null,    
FifteentoTwentyOne Decimal(18,6) null,    
TwentyTwotoThirty Decimal(18,6) null,    
LessthanThirty Decimal(18,6) null,    
ThirtyOnetoSixty Decimal(18,6) null,    
SixtyOnetoNinety Decimal(18,6) null,    
MorethanNinety Decimal(18,6) null)    
          
  
  
insert #temp(SalesmanID, Salesman_Name, Value, OnetoSeven, EighttoTen, EleventoFourteen,    
FifteentoTwentyOne, TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,     
SixtyOnetoNinety, MorethanNinety)    
  
  
select Isnull(collections.salesmanid, 0),           
"Salesman Name"= case collections.Salesmanid  
when 0 then @OTHERS
else Salesman_Name        
end,  
Sum(Value),  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From collections t1,Collectiondetail     
where collectiondetail.DocumentDate between @Seven and @One    
and Collectiondetail.DocumentType in (4,5)  
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.salesmanId=collections.salesmanId  
--and collections.Salesmanid *=salesman.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @Ten and @Eight    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @Fourteen and @Eleven    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @TwentyOne and @Fifteen    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @Thirty  and @TwentyTwo    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and collectiondetail.collectionId =t1.documentid),  
  
  
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate > @Thirty      
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
  
    
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @Sixty  and @ThirtyOne    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and collectiondetail.collectionId = t1.documentid),  
  
  
    
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate between @Ninety  and @SixtyOne    
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid),  
  
  
    
(Select IsNull(sum(Collectiondetail.Adjustedamount), 0)    
From Collections t1,Collectiondetail  
where collectiondetail.DocumentDate < @Ninety      
and Collectiondetail.DocumentType in (4,5)    
and Isnull(t1.status,0)&64=0   
and Isnull(t1.status,0)& 128 =0   
and t1.Salesmanid =collections.salesmanId    
and  collectiondetail.collectionId = t1.documentid)  
  
  
from collections,collectiondetail,salesman    
where collections.Salesmanid *=salesman.salesmanId    
--d collections.documentdate between @FROMDATE and @TODATE       
and (IsNull(Collections.Status, 0) & 64) = 0         
And (IsNull(Collections.Status,0) & 128) = 0         
and collectiondetail.DocumentType in (4,5)    
and  collectiondetail.collectionId = collections.documentid  
group by collections.salesmanid,salesman.salesman_name  
Select  "SalesmanID" = SalesmanID,     
"Salesman Name" = Salesman_Name,  
"Toal Collections (%c)" = Value,    
"1-7 Days" = OnetoSeven,    
"8-10 Days" = EighttoTen,    
"11-14 Days" = EleventoFourteen,    
"15-21 Days" = FifteentoTwentyOne,    
"22-30 Days" = TwentyTwotoThirty,    
"<30 Days" =  LessthanThirty,    
"31-60 Days" = ThirtyOnetoSixty,    
"61-90 Days" = SixtyOnetoNinety,    
">90 Days" = MorethanNinety    
From #temp where salesman_name like @salesman
