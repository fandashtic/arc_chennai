CREATE PROCEDURE sp_acc_rpt_ReceivedPriceList(@ProductHierarchy nVarchar(256),   
@Category nVarchar(256),  @FromDate DateTime, @ToDate DateTime)  
AS  

CREATE Table #TempCategory(CategoryID int, Status int)                  
Exec GetLeafCategories @ProductHierarchy, @Category            
  
CREATE Table #Temp(DetailParam nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, PLDate DateTime, ReceivedDate DateTime,   
PLName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, PLDesc nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SentBy nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemsCount Int)  
  
Insert Into #Temp  
Select A.ReceiveDocID, Max(A.PriceListDate), Max(A.CreationDate), A.PriceListName,  
A.PriceListDesc, A.SentBy, "No. Of Items" = (Select Count(*) from ReceivePriceListItemDetail  
Where ReceivePriceListItemDetail.ReceiveDocID = A.ReceiveDocID)  
from ReceivePriceListAbstract A, ReceivePriceListItemDetail, Items  
Where ReceivePriceListItemDetail.ReceiveDocID = A.ReceiveDocID  
And ReceivePriceListItemDetail.ForumCode = Items.Alias  
And A.PriceListDate Between @FromDate And @ToDate  
And Items.CategoryID In (Select CategoryID from #TempCategory)  
Group By A.ReceiveDocID, A.PriceListName, A.PriceListDesc, A.SentBy  
  
Select "DetailParam" = @ProductHierarchy + N';' + @Category + N';' + DetailParam,  
       "PriceList Date" = dbo.StripDateFromTime(PLDate),  
       "Received Date" = dbo.StripDateFromTime(ReceivedDate),  
       "PriceList Name" = PLName,  
       "PriceList Description" = PLDesc,  
       "Received from" = SentBy,  
       "No. Of Items" = ItemsCount  
from #Temp  
  
Drop Table #TempCategory  
Drop Table #Temp  



