create procedure spr_list_BeatwiseOutstanding  (@FROMDATE datetime,
						@TODATE datetime)
as
select Beat.BeatID, Beat.Description, 
"OutStandingAmount" = (ISNULL((Select sum(Balance) From InvoiceAbstract Where
InvoiceAbstract.BeatID = Beat.BeatID And
InvoiceDate Between @FROMDATE And @TODATE And
InvoiceType in (1, 3) And
(Status & 128) = 0) ,0) - ISNULL((Select Sum(Balance) From InvoiceAbstract Where
InvoiceAbstract.BeatID = Beat.BeatID And
InvoiceDate Between @FROMDATE And @TODATE And
InvoiceType = 4 And
(Status & 128) = 0), 0)) From Beat
Order By OutStandingAmount Desc
